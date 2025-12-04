import ArgumentParser
import Docc2contextCore
import Foundation

@main
struct RepositoryValidationCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "repository-validation",
        abstract: "Validate repository metadata fixtures or staged repository exports",
        discussion: "Defaults to validating the offline fixtures in Fixtures/RepositoryMetadata. Override expectations to match staged repositories before enabling live gates."
    )

    @Option(name: .long, help: "Path to the repository metadata directory (defaults to Fixtures/RepositoryMetadata)")
    var fixturesPath: String = "Fixtures/RepositoryMetadata"

    @Option(name: .long, help: "Override package version for both apt and dnf metadata")
    var packageVersion: String?

    @Option(name: .long, help: "Override apt suite value from Release/InRelease")
    var aptSuite: String?

    @Option(name: .long, parsing: .upToNextOption, help: "Override apt component list (space-separated)")
    var aptComponents: [String] = []

    @Option(name: .long, parsing: .upToNextOption, help: "Override apt architectures (space-separated)")
    var aptArchitectures: [String] = []

    @Option(name: .long, help: "Override apt origin field")
    var aptOrigin: String?

    @Option(name: .long, help: "Override apt label field")
    var aptLabel: String?

    @Option(name: .long, help: "Override apt package filename")
    var aptPackageFilename: String?

    @Option(name: .long, help: "Override apt package size")
    var aptPackageSize: Int?

    @Option(name: .long, help: "Override apt package SHA256")
    var aptPackageSHA256: String?

    @Option(name: .long, help: "Override dnf architecture")
    var dnfArchitecture: String?

    @Option(name: .long, help: "Override dnf package checksum")
    var dnfChecksum: String?

    @Option(name: .long, help: "Override dnf package location")
    var dnfLocation: String?

    @Option(name: .long, help: "Override dnf release value")
    var dnfRelease: String?

    @Option(name: .long, help: "Override dnf epoch value")
    var dnfEpoch: String?

    @Option(name: .long, help: "Override repodata primary checksum declared in repomd.xml")
    var primaryChecksum: String?

    @Flag(name: .long, help: "Skip InRelease signature presence checks")
    var skipInReleaseSignature: Bool = false

    func run() throws {
        let fixturesURL = URL(fileURLWithPath: fixturesPath)
        var expectation = RepositoryValidationExpectation.fixturesDefault()

        if let packageVersion {
            expectation.apt.version = packageVersion
            expectation.apt.package.version = packageVersion
            expectation.dnf.package.version = packageVersion
        }

        if let aptSuite {
            expectation.apt.suite = aptSuite
        }
        if let aptOrigin {
            expectation.apt.origin = aptOrigin
        }
        if let aptLabel {
            expectation.apt.label = aptLabel
        }
        if !aptComponents.isEmpty {
            expectation.apt.components = aptComponents
        }
        if !aptArchitectures.isEmpty {
            expectation.apt.architectures = aptArchitectures
        }
        if let aptPackageFilename {
            expectation.apt.package.filename = aptPackageFilename
        }
        if let aptPackageSize {
            expectation.apt.package.sizeBytes = aptPackageSize
        }
        if let aptPackageSHA256 {
            expectation.apt.package.sha256 = aptPackageSHA256
        }

        expectation.apt.requireInReleaseSignature = !skipInReleaseSignature

        if let dnfArchitecture {
            expectation.dnf.package.architecture = dnfArchitecture
        }
        if let dnfChecksum {
            expectation.dnf.package.checksum = dnfChecksum
        }
        if let dnfLocation {
            expectation.dnf.package.location = dnfLocation
        }
        if let dnfRelease {
            expectation.dnf.package.release = dnfRelease
        }
        if let dnfEpoch {
            expectation.dnf.package.epoch = dnfEpoch
        }
        if let primaryChecksum {
            expectation.dnf.primaryChecksum = primaryChecksum
        }

        let harness = RepositoryValidationHarness()
        let result = try harness.validate(fixturesDirectory: fixturesURL, expectation: expectation)

        if result.isValid {
            print("[OK] Repository metadata validated successfully at \(fixturesURL.path)")
        } else {
            for issue in result.issues {
                FileHandle.standardError.write(Data("[ERROR] \(issue)\n".utf8))
            }
            throw ExitCode.failure
        }
    }
}
