import Foundation
import XCTest

final class HomebrewFormulaBuilderTests: XCTestCase {
    func test_buildsDeterministicFormulaForBothArchitectures() throws {
        let fileManager = FileManager.default
        let scriptURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("build_homebrew_formula.py")
        XCTAssertTrue(fileManager.fileExists(atPath: scriptURL.path), "Homebrew formula builder script is missing")

        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("homebrew-formula-tests", isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }
        let outputPath = outputDirectory.appendingPathComponent("docc2context.rb")

        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "python3",
            scriptURL.path,
            "--version", "v1.2.3",
            "--arm64-url", "https://example.invalid/docc2context-v1.2.3-macos-arm64.zip",
            "--arm64-sha256", "deadbeefcafebabe",
            "--x86_64-url", "https://example.invalid/docc2context-v1.2.3-macos-x86_64.zip",
            "--x86_64-sha256", "0123456789abcdef",
            "--output", outputPath.path
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationStatus == 0 else {
            let output = String(data: outputData, encoding: .utf8) ?? "<unreadable>"
            XCTFail("build_homebrew_formula.py failed: \(output)")
            return
        }

        let contents = try String(contentsOf: outputPath, encoding: .utf8)
        let expectedFormula = [
            "class Docc2context < Formula",
            "  desc \"Convert DocC bundles to deterministic Markdown plus link graphs\"",
            "  homepage \"https://github.com/SoundBlaster/docc2context\"",
            "  version \"1.2.3\"",
            "  license \"MIT\"",
            "",
            "  on_macos do",
            "    on_arm do",
            "      url \"https://example.invalid/docc2context-v1.2.3-macos-arm64.zip\"",
            "      sha256 \"deadbeefcafebabe\"",
            "    end",
            "",
            "    on_intel do",
            "      url \"https://example.invalid/docc2context-v1.2.3-macos-x86_64.zip\"",
            "      sha256 \"0123456789abcdef\"",
            "    end",
            "  end",
            "",
            "  def install",
            "    bin.install \"docc2context\"",
            "    prefix.install \"README.md\", \"LICENSE\"",
            "  end",
            "",
            "  test do",
            "    assert_match version.to_s, shell_output(\"#{bin}/docc2context --version\")",
            "  end",
            "end",
            ""
        ].joined(separator: "\n")

        XCTAssertEqual(contents, expectedFormula, "Homebrew formula output must be deterministic")
    }
}
