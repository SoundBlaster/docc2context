import Crypto
import Foundation
#if canImport(FoundationXML)
import FoundationXML
#else
// XMLParser and XMLParserDelegate live in Foundation on platforms where FoundationXML
// is unavailable (e.g., some macOS environments). Provide aliases so the harness
// continues to compile without importing the separate module.
private typealias XMLParser = Foundation.XMLParser
private typealias XMLParserDelegate = Foundation.XMLParserDelegate
#endif

public struct RepositoryValidationExpectation {
    public struct AptPackageExpectation: Equatable {
        public var name: String
        public var version: String
        public var architecture: String
        public var filename: String
        public var sizeBytes: Int
        public var sha256: String

        public init(name: String, version: String, architecture: String, filename: String, sizeBytes: Int, sha256: String) {
            self.name = name
            self.version = version
            self.architecture = architecture
            self.filename = filename
            self.sizeBytes = sizeBytes
            self.sha256 = sha256
        }
    }

    public struct AptExpectation: Equatable {
        public var origin: String
        public var label: String
        public var suite: String
        public var version: String
        public var architectures: [String]
        public var components: [String]
        public var package: AptPackageExpectation
        public var requireInReleaseSignature: Bool

        public init(
            origin: String,
            label: String,
            suite: String,
            version: String,
            architectures: [String],
            components: [String],
            package: AptPackageExpectation,
            requireInReleaseSignature: Bool = true
        ) {
            self.origin = origin
            self.label = label
            self.suite = suite
            self.version = version
            self.architectures = architectures
            self.components = components
            self.package = package
            self.requireInReleaseSignature = requireInReleaseSignature
        }
    }

    public struct DnfPackageExpectation: Equatable {
        public var name: String
        public var architecture: String
        public var version: String
        public var release: String
        public var epoch: String
        public var checksum: String
        public var location: String

        public init(
            name: String,
            architecture: String,
            version: String,
            release: String,
            epoch: String,
            checksum: String,
            location: String
        ) {
            self.name = name
            self.architecture = architecture
            self.version = version
            self.release = release
            self.epoch = epoch
            self.checksum = checksum
            self.location = location
        }
    }

    public struct DnfExpectation: Equatable {
        public var primaryChecksum: String
        public var package: DnfPackageExpectation

        public init(primaryChecksum: String, package: DnfPackageExpectation) {
            self.primaryChecksum = primaryChecksum
            self.package = package
        }
    }

    public var apt: AptExpectation
    public var dnf: DnfExpectation

    public init(apt: AptExpectation, dnf: DnfExpectation) {
        self.apt = apt
        self.dnf = dnf
    }

    public static func fixturesDefault() -> RepositoryValidationExpectation {
        let aptPackage = AptPackageExpectation(
            name: "docc2context",
            version: "0.0.0-test",
            architecture: "amd64",
            filename: "pool/main/d/docc2context/docc2context_0.0.0-test_amd64.deb",
            sizeBytes: 1024,
            sha256: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        )
        let apt = AptExpectation(
            origin: "docc2context",
            label: "docc2context",
            suite: "stable",
            version: "0.0.0-test",
            architectures: ["amd64"],
            components: ["main"],
            package: aptPackage
        )

        let dnfPackage = DnfPackageExpectation(
            name: "docc2context",
            architecture: "x86_64",
            version: "0.0.0-test",
            release: "1",
            epoch: "0",
            checksum: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            location: "packages/docc2context-0.0.0-test-1.x86_64.rpm"
        )
        let dnf = DnfExpectation(
            primaryChecksum: "7e0765dc3bf8a54a5c22e5eda6aa016d0052b64e6f840eb99b16cb058a5fd7fc",
            package: dnfPackage
        )

        return RepositoryValidationExpectation(apt: apt, dnf: dnf)
    }
}

public struct RepositoryValidationIssue: Equatable, CustomStringConvertible {
    public let path: String
    public let message: String

    public var description: String {
        "\(path): \(message)"
    }
}

public struct RepositoryValidationResult: Equatable {
    public let issues: [RepositoryValidationIssue]

    public var isValid: Bool { issues.isEmpty }
}

public struct RepositoryValidationHarness {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func validate(fixturesDirectory: URL, expectation: RepositoryValidationExpectation) throws -> RepositoryValidationResult {
        var issues: [RepositoryValidationIssue] = []

        let aptDirectory = fixturesDirectory.appendingPathComponent("apt", isDirectory: true)
        let dnfDirectory = fixturesDirectory.appendingPathComponent("dnf", isDirectory: true)

        issues.append(contentsOf: try validateAptMetadata(at: aptDirectory, expectation: expectation.apt))
        issues.append(contentsOf: try validateDnfMetadata(at: dnfDirectory, expectation: expectation.dnf))

        return RepositoryValidationResult(issues: issues)
    }

    private func validateAptMetadata(at directory: URL, expectation: RepositoryValidationExpectation.AptExpectation) throws -> [RepositoryValidationIssue] {
        var issues: [RepositoryValidationIssue] = []
        let releaseURL = directory.appendingPathComponent("Release", isDirectory: false)
        let packagesURL = directory.appendingPathComponent("Packages", isDirectory: false)
        let inReleaseURL = directory.appendingPathComponent("InRelease", isDirectory: false)

        let releaseContents = try String(contentsOf: releaseURL, encoding: .utf8)
        let releaseFields = parseKeyValuePairs(from: releaseContents)

        issues.append(contentsOf: compareField("Origin", in: releaseFields, expected: expectation.origin, path: releaseURL.path))
        issues.append(contentsOf: compareField("Label", in: releaseFields, expected: expectation.label, path: releaseURL.path))
        issues.append(contentsOf: compareField("Suite", in: releaseFields, expected: expectation.suite, path: releaseURL.path))
        issues.append(contentsOf: compareField("Version", in: releaseFields, expected: expectation.version, path: releaseURL.path))

        if let architectures = releaseFields["Architectures"] {
            let parsedArchitectures = architectures.split(separator: " ").map(String.init)
            if Set(parsedArchitectures) != Set(expectation.architectures) {
                issues.append(
                    RepositoryValidationIssue(
                        path: releaseURL.path,
                        message: "Architectures mismatch: expected \(expectation.architectures.joined(separator: ", ")), found \(parsedArchitectures.joined(separator: ", "))"
                    )
                )
            }
        } else {
            issues.append(RepositoryValidationIssue(path: releaseURL.path, message: "Missing Architectures field"))
        }

        if let components = releaseFields["Components"] {
            let parsedComponents = components.split(separator: " ").map(String.init)
            if Set(parsedComponents) != Set(expectation.components) {
                issues.append(
                    RepositoryValidationIssue(
                        path: releaseURL.path,
                        message: "Components mismatch: expected \(expectation.components.joined(separator: ", ")), found \(parsedComponents.joined(separator: ", "))"
                    )
                )
            }
        } else {
            issues.append(RepositoryValidationIssue(path: releaseURL.path, message: "Missing Components field"))
        }

        let packagesData = try Data(contentsOf: packagesURL)
        let packagesHash = sha256Hex(for: packagesData)
        if let hashFromRelease = parseReleaseHash(for: "Packages", in: releaseContents) {
            if hashFromRelease != packagesHash {
                issues.append(
                    RepositoryValidationIssue(
                        path: releaseURL.path,
                        message: "Packages hash mismatch: expected \(hashFromRelease), computed \(packagesHash)"
                    )
                )
            }
        } else {
            issues.append(RepositoryValidationIssue(path: releaseURL.path, message: "Missing Packages hash entry"))
        }

        let packagesEntries = parseDebianControlEntries(from: packagesData)
        guard let packageEntry = packagesEntries.first else {
            issues.append(RepositoryValidationIssue(path: packagesURL.path, message: "No package entries found"))
            return issues
        }

        issues.append(contentsOf: compareField("Package", in: packageEntry, expected: expectation.package.name, path: packagesURL.path))
        issues.append(contentsOf: compareField("Version", in: packageEntry, expected: expectation.package.version, path: packagesURL.path))
        issues.append(contentsOf: compareField("Architecture", in: packageEntry, expected: expectation.package.architecture, path: packagesURL.path))
        issues.append(contentsOf: compareField("Filename", in: packageEntry, expected: expectation.package.filename, path: packagesURL.path))

        if let sizeString = packageEntry["Size"], let size = Int(sizeString.trimmingCharacters(in: .whitespaces)), size != expectation.package.sizeBytes {
            issues.append(
                RepositoryValidationIssue(
                    path: packagesURL.path,
                    message: "Size mismatch: expected \(expectation.package.sizeBytes), found \(size)"
                )
            )
        }

        if let sha = packageEntry["SHA256"] {
            if sha.lowercased() != expectation.package.sha256.lowercased() {
                issues.append(
                    RepositoryValidationIssue(
                        path: packagesURL.path,
                        message: "SHA256 field mismatch: expected \(expectation.package.sha256), found \(sha)"
                    )
                )
            }
            if !isValidHexDigest(sha) {
                issues.append(RepositoryValidationIssue(path: packagesURL.path, message: "SHA256 field is not a valid hex digest"))
            }
        } else {
            issues.append(RepositoryValidationIssue(path: packagesURL.path, message: "Missing SHA256 field"))
        }

        if expectation.requireInReleaseSignature {
            let inReleaseContents = try String(contentsOf: inReleaseURL, encoding: .utf8)
            if !inReleaseContents.contains("PGP SIGNATURE") {
                issues.append(RepositoryValidationIssue(path: inReleaseURL.path, message: "InRelease signature block missing"))
            }
        }

        return issues
    }

    private func validateDnfMetadata(at directory: URL, expectation: RepositoryValidationExpectation.DnfExpectation) throws -> [RepositoryValidationIssue] {
        var issues: [RepositoryValidationIssue] = []
        let repomdURL = directory.appendingPathComponent("repodata", isDirectory: true).appendingPathComponent("repomd.xml", isDirectory: false)
        let primaryURL = directory.appendingPathComponent("repodata", isDirectory: true).appendingPathComponent("primary.xml", isDirectory: false)

        let repomdData = try Data(contentsOf: repomdURL)
        let repomd = try parseRepomd(from: repomdData)

        if let primaryChecksum = repomd.primaryChecksum {
            let actualChecksum = sha256Hex(for: try Data(contentsOf: primaryURL))
            if primaryChecksum != actualChecksum {
                issues.append(
                    RepositoryValidationIssue(
                        path: repomdURL.path,
                        message: "repodata/primary.xml hash mismatch: expected \(primaryChecksum), computed \(actualChecksum)"
                    )
                )
            }
        } else {
            issues.append(RepositoryValidationIssue(path: repomdURL.path, message: "Missing primary checksum entry"))
        }

        if let href = repomd.primaryLocation, href != "repodata/primary.xml" {
            issues.append(RepositoryValidationIssue(path: repomdURL.path, message: "Unexpected primary location: \(href)"))
        }

        let primaryData = try Data(contentsOf: primaryURL)
        let primaryPackage = try parsePrimaryPackage(from: primaryData)

        if primaryPackage.name != expectation.package.name {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Package name mismatch: expected \(expectation.package.name), found \(primaryPackage.name)"))
        }
        if primaryPackage.architecture != expectation.package.architecture {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Architecture mismatch: expected \(expectation.package.architecture), found \(primaryPackage.architecture)"))
        }
        if primaryPackage.version != expectation.package.version {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Version mismatch: expected \(expectation.package.version), found \(primaryPackage.version)"))
        }
        if primaryPackage.release != expectation.package.release {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Release mismatch: expected \(expectation.package.release), found \(primaryPackage.release)"))
        }
        if primaryPackage.epoch != expectation.package.epoch {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Epoch mismatch: expected \(expectation.package.epoch), found \(primaryPackage.epoch)"))
        }
        if primaryPackage.checksum.lowercased() != expectation.package.checksum.lowercased() {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Checksum mismatch: expected \(expectation.package.checksum), found \(primaryPackage.checksum)"))
        }
        if primaryPackage.location != expectation.package.location {
            issues.append(RepositoryValidationIssue(path: primaryURL.path, message: "Location mismatch: expected \(expectation.package.location), found \(primaryPackage.location)"))
        }

        if repomd.primaryChecksum != expectation.primaryChecksum {
            issues.append(RepositoryValidationIssue(path: repomdURL.path, message: "Primary checksum entry mismatch: expected \(expectation.primaryChecksum), found \(repomd.primaryChecksum ?? "<missing>")"))
        }

        return issues
    }

    private func parseKeyValuePairs(from contents: String) -> [String: String] {
        var pairs: [String: String] = [:]
        for line in contents.split(separator: "\n") {
            guard let separatorIndex = line.firstIndex(of: ":") else { continue }
            let key = line[..<separatorIndex].trimmingCharacters(in: .whitespaces)
            let value = line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespaces)
            if !key.isEmpty {
                pairs[key] = value
            }
        }
        return pairs
    }

    private func parseReleaseHash(for file: String, in contents: String) -> String? {
        var isInHashSection = false
        for line in contents.split(separator: "\n") {
            if line.trimmingCharacters(in: .whitespaces) == "SHA256:" {
                isInHashSection = true
                continue
            }
            guard isInHashSection else { continue }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            let columns = trimmed.split(whereSeparator: { $0.isWhitespace })
            guard columns.count >= 2 else { continue }
            let hash = String(columns[0])
            let path = String(columns[columns.count - 1])
            if path.hasSuffix(file) {
                return hash
            }
        }
        return nil
    }

    private func parseDebianControlEntries(from data: Data) -> [[String: String]] {
        guard let contents = String(data: data, encoding: .utf8) else {
            return []
        }
        var entries: [[String: String]] = []
        var current: [String: String] = [:]

        func commitCurrentIfNeeded() {
            if !current.isEmpty {
                entries.append(current)
                current = [:]
            }
        }

        for line in contents.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                commitCurrentIfNeeded()
                continue
            }
            guard let separatorIndex = line.firstIndex(of: ":") else { continue }
            let key = line[..<separatorIndex].trimmingCharacters(in: .whitespaces)
            let value = line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespaces)
            current[key] = value
        }
        commitCurrentIfNeeded()
        return entries
    }

    private func compareField(_ field: String, in dictionary: [String: String], expected: String, path: String) -> [RepositoryValidationIssue] {
        guard let actual = dictionary[field] else {
            return [RepositoryValidationIssue(path: path, message: "Missing \(field) field")]
        }
        if actual == expected {
            return []
        }
        return [RepositoryValidationIssue(path: path, message: "\(field) mismatch: expected \(expected), found \(actual)")]
    }

    private func sha256Hex(for data: Data) -> String {
        var hasher = SHA256()
        hasher.update(data: data)
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func isValidHexDigest(_ value: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        return value.count == 64 && value.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}

private struct RepomdDocument {
    var primaryChecksum: String?
    var primaryLocation: String?
}

private struct PrimaryPackage {
    var name: String = ""
    var architecture: String = ""
    var version: String = ""
    var release: String = ""
    var epoch: String = ""
    var checksum: String = ""
    var location: String = ""
}

private enum RepositoryValidationError: Error {
    case parseError(String)
}

private extension RepositoryValidationHarness {
    func parseRepomd(from data: Data) throws -> RepomdDocument {
        let parser = XMLParser(data: data)
        let delegate = RepomdParserDelegate()
        parser.delegate = delegate
        guard parser.parse() else {
            throw RepositoryValidationError.parseError("Failed to parse repomd.xml")
        }
        return RepomdDocument(primaryChecksum: delegate.primaryChecksum, primaryLocation: delegate.primaryLocation)
    }

    func parsePrimaryPackage(from data: Data) throws -> PrimaryPackage {
        let parser = XMLParser(data: data)
        let delegate = PrimaryParserDelegate()
        parser.delegate = delegate
        guard parser.parse() else {
            throw RepositoryValidationError.parseError("Failed to parse primary.xml")
        }
        guard let package = delegate.package else {
            throw RepositoryValidationError.parseError("No package entry found in primary.xml")
        }
        return package
    }
}

private final class RepomdParserDelegate: NSObject, XMLParserDelegate {
    var primaryChecksum: String?
    var primaryLocation: String?
    private var currentType: String?
    private var buffer: String = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        buffer = ""
        if elementName == "data" {
            currentType = attributeDict["type"]
        }
        if elementName == "location", currentType == "primary" {
            primaryLocation = attributeDict["href"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        defer { buffer = "" }
        guard currentType == "primary" else { return }
        if elementName == "checksum" {
            primaryChecksum = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

private final class PrimaryParserDelegate: NSObject, XMLParserDelegate {
    var package: PrimaryPackage?
    private var currentPackage: PrimaryPackage?
    private var buffer: String = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        buffer = ""

        if elementName == "package" {
            currentPackage = PrimaryPackage()
        } else if elementName == "version", var pkg = currentPackage {
            pkg.version = attributeDict["ver"] ?? pkg.version
            pkg.release = attributeDict["rel"] ?? pkg.release
            pkg.epoch = attributeDict["epoch"] ?? pkg.epoch
            currentPackage = pkg
        } else if elementName == "location", var pkg = currentPackage {
            pkg.location = attributeDict["href"] ?? pkg.location
            currentPackage = pkg
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        defer { buffer = "" }
        guard var pkg = currentPackage else { return }

        let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "name":
            pkg.name = trimmed
        case "arch":
            pkg.architecture = trimmed
        case "checksum":
            pkg.checksum = trimmed
        default:
            break
        }
        currentPackage = pkg

        if elementName == "package" {
            package = pkg
            currentPackage = nil
        }
    }
}
