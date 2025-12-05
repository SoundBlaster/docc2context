import XCTest
@testable import Docc2contextCore

final class RepositoryValidationHarnessTests: XCTestCase {
    func testFixtureValidationSucceeds() throws {
        let fixturesRoot = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata", isDirectory: true)
        let configuration = RepositoryValidationHarness.Configuration.fixtures(baseDirectory: fixturesRoot)
        let harness = RepositoryValidationHarness()

        let result = try harness.validate(configuration: configuration)

        XCTAssertTrue(result.isValid, "Expected fixtures to pass validation, found issues: \(result.issues)")
        XCTAssertEqual(result.issues, [])
    }

    func testDetectsTamperedAptAndDnfMetadata() throws {
        try TestTemporaryDirectory.withTemporaryDirectory { temporaryDirectory in
            let sourceDirectory = TestSupportPaths.fixturesDirectory.appendingPathComponent("RepositoryMetadata", isDirectory: true)
            let workingDirectory = temporaryDirectory.url.appendingPathComponent("RepositoryMetadata", isDirectory: true)
            try FileManager.default.copyItem(at: sourceDirectory, to: workingDirectory)

            let packagesPath = workingDirectory.appendingPathComponent("apt/Packages")
            try "Package: docc2context\nVersion: 9.9.9-bad\n".write(to: packagesPath, atomically: true, encoding: .utf8)

            let primaryPath = workingDirectory.appendingPathComponent("dnf/repodata/primary.xml")
            let corruptedPrimary = """
            <?xml version=\"1.0\" encoding=\"UTF-8\"?>
            <metadata packages=\"1\">
              <package type=\"rpm\">
                <name>docc2context</name>
                <arch>x86_64</arch>
                <version epoch=\"0\" ver=\"0.0.0-test\" rel=\"1\"/>
                <checksum type=\"sha256\" pkgid=\"YES\">deadbeef</checksum>
                <location href=\"packages/docc2context-0.0.0-test-1.x86_64.rpm\"/>
              </package>
            </metadata>
            """
            try corruptedPrimary.write(to: primaryPath, atomically: true, encoding: .utf8)

            let configuration = RepositoryValidationHarness.Configuration.fixtures(baseDirectory: workingDirectory)
            let harness = RepositoryValidationHarness()
            let result = try harness.validate(configuration: configuration)

            XCTAssertFalse(result.isValid)
            let identifiers = result.issues.map(\.identifier)
            XCTAssertTrue(identifiers.contains("manifest"))
            XCTAssertTrue(identifiers.contains("apt-packages"))
            XCTAssertTrue(identifiers.contains("dnf-primary"))
            XCTAssertTrue(result.issues.contains { $0.message.contains("Package version") })
            XCTAssertTrue(result.issues.contains { $0.message.contains("primary checksum") })
        }
    }
}
