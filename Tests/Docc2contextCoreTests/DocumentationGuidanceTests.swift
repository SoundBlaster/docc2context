import XCTest

final class DocumentationGuidanceTests: XCTestCase {
    private func loadDocumentation(path: String) throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(path)
        return try String(contentsOf: url, encoding: .utf8)
    }

    func test_docsIncludeFixturesAndReleaseGuidance() throws {
        let fixtures = try loadDocumentation(path: "DOCS/README/fixtures.md")
        XCTAssertTrue(fixtures.contains("Fixtures/manifest.json"), "Docs should document the fixture manifest")
        XCTAssertTrue(fixtures.contains("Scripts/validate_fixtures_manifest.py"), "Docs should mention the fixture validation script")

        let contributing = try loadDocumentation(path: "DOCS/README/contributing.md")
        XCTAssertTrue(contributing.contains("swift test --enable-code-coverage"), "Docs should tell contributors how to run coverage-enabled tests")
        XCTAssertTrue(contributing.contains("python3 Scripts/enforce_coverage.py"), "Docs should reference the coverage helper script")

        let releases = try loadDocumentation(path: "DOCS/README/releases.md")
        XCTAssertTrue(releases.contains("Scripts/release_gates.sh"), "Docs should describe running release gates")
        XCTAssertTrue(releases.contains("Scripts/package_release.sh"), "Docs should describe the release packaging script")
        XCTAssertTrue(releases.contains("brew tap docc2context/tap"), "Docs should document the Homebrew tap for macOS users")
        XCTAssertTrue(releases.contains("install_macos.sh"), "Docs should mention the macOS install helper script")
        XCTAssertTrue(releases.localizedCaseInsensitiveContains("codesign"), "Docs should reference macOS codesigning guidance")
        XCTAssertTrue(releases.localizedCaseInsensitiveContains("notarytool"), "Docs should outline macOS notarization steps")
    }

    func test_docsIncludeTroubleshootingGuidance() throws {
        let troubleshooting = try loadDocumentation(path: "DOCS/README/troubleshooting.md")
        XCTAssertTrue(troubleshooting.contains("## Markdown lint failures"), "Docs should contain a troubleshooting section for contributors")
        XCTAssertTrue(troubleshooting.contains("Scripts/lint_markdown.py"), "Docs should mention the Markdown lint workflow")
    }
}
