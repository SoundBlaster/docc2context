import XCTest
@testable import Docc2contextCore

final class RepositoryValidationCommandCoverageTests: XCTestCase {
    private final class StubHarness: RepositoryValidationHarnessing {
        let result: RepositoryValidationHarness.Result
        var capturedConfiguration: RepositoryValidationHarness.Configuration?

        init(result: RepositoryValidationHarness.Result) {
            self.result = result
        }

        func validate(configuration: RepositoryValidationHarness.Configuration) throws -> RepositoryValidationHarness.Result {
            capturedConfiguration = configuration
            return result
        }
    }

    func testDefaultFixturesPathIsUsedWhenNotProvided() {
        let harness = StubHarness(result: .init(issues: []))
        let command = RepositoryValidationCommand(harness: harness)
        let output = command.run(arguments: ["repository-validation"])
        XCTAssertEqual(output.exitCode, 0)
        XCTAssertTrue(output.output.contains("Validation succeeded"))
        let capturedPath = harness.capturedConfiguration?.paths.fixturesRoot.path ?? ""
        XCTAssertTrue(capturedPath.hasSuffix("Fixtures/RepositoryMetadata"))
    }

    func testBuildConfigurationUsesOverrides() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
        let fixturesRoot = temporaryDirectory.url
        let overrideAptRelease = fixturesRoot.appendingPathComponent("custom/Release")
        let overrideAptInRelease = fixturesRoot.appendingPathComponent("custom/InRelease")
        let overrideAptPackages = fixturesRoot.appendingPathComponent("custom/Packages")
        let overrideDnfRepomd = fixturesRoot.appendingPathComponent("custom/repodata/repomd.xml")
        let overrideDnfPrimary = fixturesRoot.appendingPathComponent("custom/repodata/primary.xml")
        let manifestURL = fixturesRoot.appendingPathComponent("manifest.json")

        for url in [overrideAptRelease, overrideAptInRelease, overrideAptPackages, overrideDnfRepomd, overrideDnfPrimary] {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data("x".utf8).write(to: url)
        }
        try Data("{}".utf8).write(to: manifestURL)

        let stub = StubHarness(result: .init(issues: []))
        let command = RepositoryValidationCommand(harness: stub)

        let args = [
            "repository-validation",
            "--fixtures-path", fixturesRoot.path,
            "--apt-release", overrideAptRelease.path,
            "--apt-inrelease", overrideAptInRelease.path,
            "--apt-packages", overrideAptPackages.path,
            "--dnf-repomd", overrideDnfRepomd.path,
            "--dnf-primary", overrideDnfPrimary.path,
            "--expected-deb-sha256", String(repeating: "f", count: 64),
            "--expected-rpm-sha256", String(repeating: "f", count: 64),
            "--expected-deb-size", "1",
            "--expected-deb-filename", overrideAptPackages.lastPathComponent,
            "--expected-rpm-location", overrideDnfPrimary.lastPathComponent,
            "--expected-version", "0.0.0-test"
        ]

        let result = command.run(arguments: args)
        XCTAssertEqual(result.exitCode, 0)
        let config = try XCTUnwrap(stub.capturedConfiguration)
        XCTAssertEqual(config.paths.aptRelease.path, overrideAptRelease.path)
        XCTAssertEqual(config.paths.dnfPrimary.path, overrideDnfPrimary.path)
        }
    }
}
