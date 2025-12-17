import ArgumentParser
import Foundation

public protocol RepositoryValidationHarnessing {
    func validate(configuration: RepositoryValidationHarness.Configuration) throws -> RepositoryValidationHarness.Result
}

extension RepositoryValidationHarness: RepositoryValidationHarnessing {}

public struct RepositoryValidationCommand {
    enum ExitCode {
        static let usageError = 64
        static let validationFailed = 1
    }

    private let harness: RepositoryValidationHarnessing

    public init(harness: RepositoryValidationHarnessing = RepositoryValidationHarness()) {
        self.harness = harness
    }

    public func run(arguments: [String]) -> Docc2contextCommandResult {
        var trimmedArguments = arguments
        if !trimmedArguments.isEmpty {
            trimmedArguments.removeFirst()
        }

        do {
            let options = try RepositoryValidationCLIOptions.parse(trimmedArguments)
            let configuration = try buildConfiguration(options: options)
            let result = try harness.validate(configuration: configuration)

            let ignoredArguments = options.unrecognizedArguments
            let ignoredArgumentsMessage: String?
            if !ignoredArguments.isEmpty {
                ignoredArgumentsMessage = "Ignored unexpected arguments: \(ignoredArguments.joined(separator: " "))"
            } else {
                ignoredArgumentsMessage = nil
            }

            if result.isValid {
                var successSummary = "Validation succeeded for \(options.expectedPackageName) version \(options.expectedVersion)"
                if let ignoredArgumentsMessage {
                    successSummary.append("\n\(ignoredArgumentsMessage)")
                }

                return Docc2contextCommandResult(exitCode: 0, output: successSummary)
            }

            let details = result.issues
                .map { "- [\($0.identifier)] \($0.message)" }
                .joined(separator: "\n")
            var output = "Validation failed:\n\(details)"
            if let ignoredArgumentsMessage {
                output.append("\n\(ignoredArgumentsMessage)")
            }
            return Docc2contextCommandResult(exitCode: ExitCode.validationFailed, output: output)
        } catch let error as ValidationError {
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: error.description)
        } catch {
            return Docc2contextCommandResult(exitCode: ExitCode.validationFailed, output: String(describing: error))
        }
    }

    private func buildConfiguration(options: RepositoryValidationCLIOptions) throws -> RepositoryValidationHarness.Configuration {
        let fixturesRoot = URL(fileURLWithPath: options.fixturesPath ?? defaultFixturesPath())
        let aptRelease = URL(fileURLWithPath: options.aptRelease ?? fixturesRoot.appendingPathComponent("apt/Release").path)
        let aptInRelease = URL(fileURLWithPath: options.aptInRelease ?? fixturesRoot.appendingPathComponent("apt/InRelease").path)
        let aptPackages = URL(fileURLWithPath: options.aptPackages ?? fixturesRoot.appendingPathComponent("apt/Packages").path)
        let dnfRepomd = URL(fileURLWithPath: options.dnfRepomd ?? fixturesRoot.appendingPathComponent("dnf/repodata/repomd.xml").path)
        let dnfPrimary = URL(fileURLWithPath: options.dnfPrimary ?? fixturesRoot.appendingPathComponent("dnf/repodata/primary.xml").path)

        let paths = RepositoryValidationHarness.Configuration.Paths(
            fixturesRoot: fixturesRoot,
            manifestURL: fixturesRoot.appendingPathComponent("manifest.json"),
            aptRelease: aptRelease,
            aptInRelease: aptInRelease,
            aptPackages: aptPackages,
            dnfRepomd: dnfRepomd,
            dnfPrimary: dnfPrimary
        )

        let expected = RepositoryValidationHarness.Configuration.ExpectedPackageMetadata(
            name: options.expectedPackageName,
            version: options.expectedVersion,
            debArchitecture: options.expectedDebArchitecture,
            debFilename: options.expectedDebFilename,
            debSHA256: options.expectedDebSHA256,
            debSize: options.expectedDebSize,
            aptComponent: options.expectedAptComponent,
            rpmArchitecture: options.expectedRpmArchitecture,
            rpmLocation: options.expectedRpmLocation,
            rpmSHA256: options.expectedRpmSHA256
        )

        return RepositoryValidationHarness.Configuration(paths: paths, expectedPackage: expected)
    }

    private func defaultFixturesPath() -> String {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return cwd.appendingPathComponent("Fixtures/RepositoryMetadata").path
    }
}

struct RepositoryValidationCLIOptions: ParsableArguments {
    @Option(name: .customLong("fixtures-path"), help: "Directory containing apt/dnf metadata and manifest.json. Defaults to Fixtures/RepositoryMetadata")
    var fixturesPath: String?

    @Option(name: .customLong("apt-release"), help: "Path to apt Release file override")
    var aptRelease: String?

    @Option(name: .customLong("apt-inrelease"), help: "Path to apt InRelease file override")
    var aptInRelease: String?

    @Option(name: .customLong("apt-packages"), help: "Path to apt Packages file override")
    var aptPackages: String?

    @Option(name: .customLong("dnf-repomd"), help: "Path to dnf repomd.xml override")
    var dnfRepomd: String?

    @Option(name: .customLong("dnf-primary"), help: "Path to dnf primary.xml override")
    var dnfPrimary: String?

    @Option(name: .customLong("expected-package-name"), help: "Expected package name for both apt and dnf metadata")
    var expectedPackageName: String = "docc2context"

    @Option(name: .customLong("expected-version"), help: "Expected package version")
    var expectedVersion: String = "0.0.0-test"

    @Option(name: .customLong("expected-deb-architecture"), help: "Expected apt Architecture field")
    var expectedDebArchitecture: String = "amd64"

    @Option(name: .customLong("expected-deb-filename"), help: "Expected apt Filename field")
    var expectedDebFilename: String = "pool/main/d/docc2context/docc2context_0.0.0-test_amd64.deb"

    @Option(name: .customLong("expected-deb-sha256"), help: "Expected apt SHA256 value for the package")
    var expectedDebSHA256: String = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

    @Option(name: .customLong("expected-deb-size"), help: "Expected apt package Size value")
    var expectedDebSize: Int = 1024

    @Option(name: .customLong("expected-apt-component"), help: "Expected apt component value")
    var expectedAptComponent: String = "main"

    @Option(name: .customLong("expected-rpm-architecture"), help: "Expected rpm architecture")
    var expectedRpmArchitecture: String = "x86_64"

    @Option(name: .customLong("expected-rpm-location"), help: "Expected rpm location href from primary.xml")
    var expectedRpmLocation: String = "packages/docc2context-0.0.0-test-1.x86_64.rpm"

    @Option(name: .customLong("expected-rpm-sha256"), help: "Expected rpm checksum value")
    var expectedRpmSHA256: String = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

    @Argument(parsing: .captureForPassthrough, help: "Additional arguments are ignored for compatibility with older workflows.")
    var unrecognizedArguments: [String] = []
}
