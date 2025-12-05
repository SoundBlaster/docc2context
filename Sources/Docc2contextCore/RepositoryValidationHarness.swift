import Crypto
import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct RepositoryValidationHarness {
    public struct Configuration {
        public struct Paths {
            public var fixturesRoot: URL
            public var manifestURL: URL?
            public var aptRelease: URL
            public var aptInRelease: URL
            public var aptPackages: URL
            public var dnfRepomd: URL
            public var dnfPrimary: URL

            public init(
                fixturesRoot: URL,
                manifestURL: URL?,
                aptRelease: URL,
                aptInRelease: URL,
                aptPackages: URL,
                dnfRepomd: URL,
                dnfPrimary: URL
            ) {
                self.fixturesRoot = fixturesRoot
                self.manifestURL = manifestURL
                self.aptRelease = aptRelease
                self.aptInRelease = aptInRelease
                self.aptPackages = aptPackages
                self.dnfRepomd = dnfRepomd
                self.dnfPrimary = dnfPrimary
            }
        }

        public struct ExpectedPackageMetadata {
            public var name: String
            public var version: String
            public var debArchitecture: String
            public var debFilename: String
            public var debSHA256: String
            public var debSize: Int
            public var aptComponent: String
            public var rpmArchitecture: String
            public var rpmLocation: String
            public var rpmSHA256: String

            public init(
                name: String,
                version: String,
                debArchitecture: String,
                debFilename: String,
                debSHA256: String,
                debSize: Int,
                aptComponent: String,
                rpmArchitecture: String,
                rpmLocation: String,
                rpmSHA256: String
            ) {
                self.name = name
                self.version = version
                self.debArchitecture = debArchitecture
                self.debFilename = debFilename
                self.debSHA256 = debSHA256
                self.debSize = debSize
                self.aptComponent = aptComponent
                self.rpmArchitecture = rpmArchitecture
                self.rpmLocation = rpmLocation
                self.rpmSHA256 = rpmSHA256
            }
        }

        public var paths: Paths
        public var expectedPackage: ExpectedPackageMetadata

        public init(paths: Paths, expectedPackage: ExpectedPackageMetadata) {
            self.paths = paths
            self.expectedPackage = expectedPackage
        }

        public static func fixtures(baseDirectory: URL) -> Configuration {
            let aptDirectory = baseDirectory.appendingPathComponent("apt", isDirectory: true)
            let dnfDirectory = baseDirectory.appendingPathComponent("dnf", isDirectory: true)

            let paths = Paths(
                fixturesRoot: baseDirectory,
                manifestURL: baseDirectory.appendingPathComponent("manifest.json"),
                aptRelease: aptDirectory.appendingPathComponent("Release"),
                aptInRelease: aptDirectory.appendingPathComponent("InRelease"),
                aptPackages: aptDirectory.appendingPathComponent("Packages"),
                dnfRepomd: dnfDirectory.appendingPathComponent("repodata/repomd.xml"),
                dnfPrimary: dnfDirectory.appendingPathComponent("repodata/primary.xml")
            )

            let expectedPackage = ExpectedPackageMetadata(
                name: "docc2context",
                version: "0.0.0-test",
                debArchitecture: "amd64",
                debFilename: "pool/main/d/docc2context/docc2context_0.0.0-test_amd64.deb",
                debSHA256: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
                debSize: 1024,
                aptComponent: "main",
                rpmArchitecture: "x86_64",
                rpmLocation: "packages/docc2context-0.0.0-test-1.x86_64.rpm",
                rpmSHA256: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
            )

            return Configuration(paths: paths, expectedPackage: expectedPackage)
        }
    }

    public struct Issue: Equatable {
        public let identifier: String
        public let message: String

        public init(identifier: String, message: String) {
            self.identifier = identifier
            self.message = message
        }
    }

    public struct Result: Equatable {
        public let issues: [Issue]

        public var isValid: Bool { issues.isEmpty }
    }

    enum HarnessError: LocalizedError {
        case missingFile(path: String)
        case xmlParsingFailed(path: String)

        var errorDescription: String? {
            switch self {
            case .missingFile(let path):
                return "Expected metadata file at \(path) but it was not found"
            case .xmlParsingFailed(let path):
                return "Failed to parse XML metadata at \(path)"
            }
        }
    }

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func validate(configuration: Configuration) throws -> Result {
        var issues: [Issue] = []

        if let manifestURL = configuration.paths.manifestURL {
            let manifestResult = try RepositoryMetadataFixturesValidator(fileManager: fileManager)
                .validate(fixturesDirectory: configuration.paths.fixturesRoot, manifestURL: manifestURL)
            issues.append(contentsOf: manifestResult.invalidEntries.map { entry in
                Issue(
                    identifier: "manifest",
                    message: "Fixture \(entry.id) mismatch: expected hash \(entry.expectedSHA256) (size \(entry.expectedSize)), actual hash \(entry.actualSHA256 ?? "missing") (size \(entry.actualSize ?? 0)) — \(entry.reason)"
                )
            })
        }

        issues.append(contentsOf: try validateApt(configuration: configuration))
        issues.append(contentsOf: try validateDnf(configuration: configuration))

        return Result(issues: issues)
    }

    // MARK: - Apt

    private struct AptReleaseMetadata {
        var version: String?
        var architectures: [String] = []
        var components: [String] = []
        var packageHash: String?
        var packagePath: String?
    }

    private struct AptPackageEntry {
        var name: String?
        var version: String?
        var architecture: String?
        var filename: String?
        var size: Int?
        var sha256: String?
    }

    private func validateApt(configuration: Configuration) throws -> [Issue] {
        let release = try parseRelease(at: configuration.paths.aptRelease)
        let packages = try parsePackages(at: configuration.paths.aptPackages)
        let inReleaseValid = try verifyInRelease(at: configuration.paths.aptInRelease, expectedVersion: configuration.expectedPackage.version)

        var aptIssues: [Issue] = []

        if !inReleaseValid {
            aptIssues.append(Issue(identifier: "apt-inrelease", message: "InRelease missing signature markers or expected version"))
        }

        var releaseMismatches: [String] = []
        if release.version != configuration.expectedPackage.version {
            releaseMismatches.append("Release version expected \(configuration.expectedPackage.version) but found \(release.version ?? "missing")")
        }
        if !release.architectures.contains(configuration.expectedPackage.debArchitecture) {
            releaseMismatches.append("Release architectures missing \(configuration.expectedPackage.debArchitecture)")
        }
        if !release.components.contains(configuration.expectedPackage.aptComponent) {
            releaseMismatches.append("Release components missing \(configuration.expectedPackage.aptComponent)")
        }

        let packagesData = try Data(contentsOf: configuration.paths.aptPackages)
        let packagesHash = sha256Hex(for: packagesData)
        if let expectedHash = release.packageHash, expectedHash != packagesHash {
            releaseMismatches.append("Packages hash mismatch: release lists \(expectedHash), actual \(packagesHash)")
        }
        if let expectedPath = release.packagePath, expectedPath != configuration.paths.aptPackages.lastPathComponent {
            releaseMismatches.append("Release Packages path \(expectedPath) does not match provided path \(configuration.paths.aptPackages.lastPathComponent)")
        }

        if !releaseMismatches.isEmpty {
            aptIssues.append(Issue(identifier: "apt-release", message: releaseMismatches.joined(separator: "; ")))
        }

        let packageIssues = validatePackageEntries(packages, expected: configuration.expectedPackage)
        if !packageIssues.isEmpty {
            aptIssues.append(Issue(identifier: "apt-packages", message: packageIssues.joined(separator: "; ")))
        }

        return aptIssues
    }

    private func parseRelease(at url: URL) throws -> AptReleaseMetadata {
        let content = try String(contentsOf: url, encoding: .utf8)
        var metadata = AptReleaseMetadata()
        var parsingHashes = false

        for rawLine in content.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line == "SHA256:" {
                parsingHashes = true
                continue
            }

            if parsingHashes {
                let parts = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                guard let hash = parts.first else { continue }
                metadata.packageHash = hash
                if parts.count >= 2 {
                    metadata.packagePath = parts.last
                }
                continue
            }

            let components = line.split(separator: ":", maxSplits: 1).map(String.init)
            guard components.count == 2 else { continue }
            let key = components[0].trimmingCharacters(in: .whitespaces)
            let value = components[1].trimmingCharacters(in: .whitespaces)

            switch key {
            case "Version":
                metadata.version = value
            case "Architectures":
                metadata.architectures = value.split(separator: " ").map(String.init)
            case "Components":
                metadata.components = value.split(separator: " ").map(String.init)
            default:
                break
            }
        }

        return metadata
    }

    private func parsePackages(at url: URL) throws -> [AptPackageEntry] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return content
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { block in
                var entry = AptPackageEntry()
                block.split(separator: "\n").forEach { line in
                    let components = line.split(separator: ":", maxSplits: 1).map(String.init)
                    guard components.count == 2 else { return }
                    let key = components[0].trimmingCharacters(in: .whitespaces)
                    let value = components[1].trimmingCharacters(in: .whitespaces)
                    switch key {
                    case "Package": entry.name = value
                    case "Version": entry.version = value
                    case "Architecture": entry.architecture = value
                    case "Filename": entry.filename = value
                    case "Size": entry.size = Int(value)
                    case "SHA256": entry.sha256 = value
                    default: break
                    }
                }
                return entry
            }
    }

    private func validatePackageEntries(
        _ entries: [AptPackageEntry],
        expected: Configuration.ExpectedPackageMetadata
    ) -> [String] {
        guard let entry = entries.first else {
            return ["No package entries found in Packages file"]
        }

        var mismatches: [String] = []
        if entry.name != expected.name {
            mismatches.append("Package name expected \(expected.name) but found \(entry.name ?? "missing")")
        }
        if entry.version != expected.version {
            mismatches.append("Package version expected \(expected.version) but found \(entry.version ?? "missing")")
        }
        if entry.architecture != expected.debArchitecture {
            mismatches.append("Package architecture expected \(expected.debArchitecture) but found \(entry.architecture ?? "missing")")
        }
        if entry.filename != expected.debFilename {
            mismatches.append("Package filename expected \(expected.debFilename) but found \(entry.filename ?? "missing")")
        }
        if entry.size != expected.debSize {
            mismatches.append("Package size expected \(expected.debSize) but found \(entry.size.map(String.init) ?? "missing")")
        }
        if entry.sha256 != expected.debSHA256 {
            mismatches.append("Package SHA256 expected \(expected.debSHA256) but found \(entry.sha256 ?? "missing")")
        }

        return mismatches
    }

    private func verifyInRelease(at url: URL, expectedVersion: String) throws -> Bool {
        let content = try String(contentsOf: url, encoding: .utf8)
        let hasSignatureMarkers = content.contains("-----BEGIN PGP SIGNED MESSAGE-----") && content.contains("-----BEGIN PGP SIGNATURE-----")
        let hasVersion = content.contains("Version: \(expectedVersion)")
        return hasSignatureMarkers && hasVersion
    }

    // MARK: - Dnf

    private struct RepomdMetadata {
        var primaryLocation: String?
        var primaryChecksum: String?
    }

    private struct DnfPackageMetadata {
        var name: String?
        var architecture: String?
        var version: String?
        var checksum: String?
        var location: String?
    }

    private func validateDnf(configuration: Configuration) throws -> [Issue] {
        let repomd = try parseRepomd(at: configuration.paths.dnfRepomd)
        let primary = try parsePrimary(at: configuration.paths.dnfPrimary)
        var issues: [Issue] = []

        let primaryData = try Data(contentsOf: configuration.paths.dnfPrimary)
        let primaryHash = sha256Hex(for: primaryData)
        if let expected = repomd.primaryChecksum, expected != primaryHash {
            issues.append(Issue(identifier: "dnf-primary", message: "repomd.xml primary checksum \(expected) does not match actual \(primaryHash)"))
        }

        var packageMismatches: [String] = []
        if primary.name != configuration.expectedPackage.name {
            packageMismatches.append("Package name expected \(configuration.expectedPackage.name) but found \(primary.name ?? "missing")")
        }
        if primary.version != configuration.expectedPackage.version {
            packageMismatches.append("Package version expected \(configuration.expectedPackage.version) but found \(primary.version ?? "missing")")
        }
        if primary.architecture != configuration.expectedPackage.rpmArchitecture {
            packageMismatches.append("Package architecture expected \(configuration.expectedPackage.rpmArchitecture) but found \(primary.architecture ?? "missing")")
        }
        if primary.location != configuration.expectedPackage.rpmLocation {
            packageMismatches.append("Package location expected \(configuration.expectedPackage.rpmLocation) but found \(primary.location ?? "missing")")
        }
        if primary.checksum != configuration.expectedPackage.rpmSHA256 {
            packageMismatches.append("Primary checksum expected \(configuration.expectedPackage.rpmSHA256) but found \(primary.checksum ?? "missing")")
        }

        if !packageMismatches.isEmpty {
            issues.append(Issue(identifier: "dnf-primary", message: packageMismatches.joined(separator: "; ")))
        }

        if repomd.primaryLocation != nil && repomd.primaryLocation != "repodata/primary.xml" {
            issues.append(Issue(identifier: "dnf-repomd", message: "repomd.xml primary location expected repodata/primary.xml but found \(repomd.primaryLocation ?? "missing")"))
        }

        return issues
    }

    private func parseRepomd(at url: URL) throws -> RepomdMetadata {
        guard let parser = XMLParser(contentsOf: url) else {
            throw HarnessError.missingFile(path: url.path)
        }
        let delegate = RepomdParserDelegate()
        parser.delegate = delegate
        guard parser.parse() else {
            throw HarnessError.xmlParsingFailed(path: url.path)
        }
        return delegate.metadata
    }

    private final class RepomdParserDelegate: NSObject, XMLParserDelegate {
        var metadata = RepomdMetadata()
        private var currentElement: String?
        private var insidePrimaryData = false

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
            if elementName == "data", attributeDict["type"] == "primary" {
                insidePrimaryData = true
            }
            if insidePrimaryData && elementName == "location", let href = attributeDict["href"] {
                metadata.primaryLocation = href
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard insidePrimaryData else { return }
            if currentElement == "checksum" {
                let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    metadata.primaryChecksum = (metadata.primaryChecksum ?? "") + trimmed
                }
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if elementName == "data" {
                insidePrimaryData = false
            }
            currentElement = nil
        }
    }

    private func parsePrimary(at url: URL) throws -> DnfPackageMetadata {
        guard let parser = XMLParser(contentsOf: url) else {
            throw HarnessError.missingFile(path: url.path)
        }
        let delegate = PrimaryParserDelegate()
        parser.delegate = delegate
        guard parser.parse() else {
            throw HarnessError.xmlParsingFailed(path: url.path)
        }
        return delegate.metadata
    }

    private final class PrimaryParserDelegate: NSObject, XMLParserDelegate {
        var metadata = DnfPackageMetadata()
        private var currentElement: String?

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
            if elementName == "package" {
                metadata = DnfPackageMetadata()
            }
            if elementName == "version" {
                metadata.version = attributeDict["ver"]
            }
            if elementName == "location", let href = attributeDict["href"] {
                metadata.location = href
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard let currentElement else { return }
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            switch currentElement {
            case "name": metadata.name = (metadata.name ?? "") + trimmed
            case "arch": metadata.architecture = (metadata.architecture ?? "") + trimmed
            case "checksum": metadata.checksum = (metadata.checksum ?? "") + trimmed
            default: break
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            currentElement = nil
        }
    }

    // MARK: - Utilities

    private func sha256Hex(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
