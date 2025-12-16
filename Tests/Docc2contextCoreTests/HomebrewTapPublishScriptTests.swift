import Foundation
import XCTest

final class HomebrewTapPublishScriptTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTestFormula(at path: URL) throws {
        let formulaContent = """
        class Docc2context < Formula
          desc "Convert DocC bundles to deterministic Markdown plus link graphs"
          homepage "https://github.com/SoundBlaster/docc2context"
          version "1.0.0"
          license "MIT"

          on_macos do
            on_arm do
              url "https://example.com/docc2context-v1.0.0-macos-arm64.zip"
              sha256 "deadbeef"
            end

            on_intel do
              url "https://example.com/docc2context-v1.0.0-macos-x86_64.zip"
              sha256 "cafebabe"
            end
          end

          def install
            bin.install "docc2context"
            prefix.install "README.md", "LICENSE"
          end

          test do
            assert_match version.to_s, shell_output("\\#{bin}/docc2context --version")
          end
        end
        """
        try formulaContent.write(to: path, atomically: true, encoding: .utf8)
    }

    private func runPushScript(
        formula: String,
        tapRepo: String,
        version: String,
        dryRun: Bool = true,
        extraArgs: [String] = []
    ) throws -> (exitCode: Int32, output: String) {
        let scriptURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("push_homebrew_formula.sh")

        var args = [
            scriptURL.path,
            "--formula", formula,
            "--tap-repo", tapRepo,
            "--version", version
        ]

        if dryRun {
            args.append("--dry-run")
        }

        args.append(contentsOf: extraArgs)

        let result = try TestProcessRunner.run(
            executableURL: URL(fileURLWithPath: "/bin/bash"),
            arguments: args,
            currentDirectoryURL: TestSupportPaths.repositoryRootDirectory,
            timeoutSeconds: 10
        )

        return (result.exitCode, result.output)
    }

    // MARK: - Tests

    func test_scriptExists() throws {
        let fileManager = FileManager.default
        let scriptURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("push_homebrew_formula.sh")

        XCTAssertTrue(
            fileManager.fileExists(atPath: scriptURL.path),
            "push_homebrew_formula.sh script must exist in Scripts/ directory"
        )
    }

    func test_dryRunPrintsIntendedActions() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let formulaPath = tempDir.appendingPathComponent("test-formula.rb")
        try createTestFormula(at: formulaPath)

        let (exitCode, output) = try runPushScript(
            formula: formulaPath.path,
            tapRepo: "https://github.com/test/homebrew-tap.git",
            version: "v1.0.0",
            dryRun: true
        )

        XCTAssertEqual(exitCode, 0, "Dry-run should succeed without errors")
        XCTAssertTrue(output.contains("DRY RUN"), "Output should indicate dry-run mode")
        XCTAssertTrue(output.contains("git clone") || output.contains("clone"), "Should mention git clone operation")
        XCTAssertTrue(output.contains("Formula/docc2context.rb"), "Should mention target formula path")
        XCTAssertTrue(output.contains("git commit") || output.contains("commit"), "Should mention git commit operation")
        XCTAssertTrue(output.contains("git push") || output.contains("push"), "Should mention git push operation")
    }

    func test_commitMessageIncludesVersion() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let formulaPath = tempDir.appendingPathComponent("test-formula.rb")
        try createTestFormula(at: formulaPath)

        let (exitCode, output) = try runPushScript(
            formula: formulaPath.path,
            tapRepo: "https://github.com/test/homebrew-tap.git",
            version: "v2.3.4",
            dryRun: true
        )

        XCTAssertEqual(exitCode, 0, "Dry-run should succeed")
        XCTAssertTrue(
            output.contains("v2.3.4") || output.contains("2.3.4"),
            "Commit message should include version number"
        )
    }

    func test_failsWithMissingFormula() throws {
        let nonExistentPath = "/tmp/nonexistent-formula-\(UUID().uuidString).rb"

        let (exitCode, output) = try runPushScript(
            formula: nonExistentPath,
            tapRepo: "https://github.com/test/homebrew-tap.git",
            version: "v1.0.0",
            dryRun: true
        )

        XCTAssertNotEqual(exitCode, 0, "Should fail when formula file doesn't exist")
        XCTAssertTrue(
            output.lowercased().contains("error") || output.lowercased().contains("not found") || output.lowercased().contains("missing"),
            "Error message should indicate missing formula file"
        )
    }

    func test_failsWithInvalidArguments() throws {
        let scriptURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("push_homebrew_formula.sh")

        let result = try TestProcessRunner.run(
            executableURL: URL(fileURLWithPath: "/bin/bash"),
            arguments: [scriptURL.path], // No arguments
            currentDirectoryURL: TestSupportPaths.repositoryRootDirectory,
            timeoutSeconds: 10
        )

        XCTAssertNotEqual(result.exitCode, 0, "Should fail with missing required arguments")
    }

    func test_dryRunCreatesNoRealGitOperations() throws {
        // This test verifies that dry-run mode doesn't actually clone or push to any repository
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let formulaPath = tempDir.appendingPathComponent("test-formula.rb")
        try createTestFormula(at: formulaPath)

        // Use a local path that doesn't exist to ensure no real git operations happen
        let fakeRepo = tempDir.appendingPathComponent("nonexistent-tap").path

        let (exitCode, output) = try runPushScript(
            formula: formulaPath.path,
            tapRepo: fakeRepo,
            version: "v1.0.0",
            dryRun: true
        )

        XCTAssertEqual(exitCode, 0, "Dry-run should succeed even with non-existent repo")
        XCTAssertTrue(output.contains("DRY RUN"), "Should clearly indicate dry-run mode")

        // Verify no git clone was actually executed
        let clonedPath = tempDir.appendingPathComponent("nonexistent-tap")
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: clonedPath.path),
            "Dry-run should not create actual git clone"
        )
    }
}
