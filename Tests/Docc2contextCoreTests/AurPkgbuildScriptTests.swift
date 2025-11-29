import Foundation
import XCTest

final class AurPkgbuildScriptTests: XCTestCase {

    private func scriptURL() -> URL {
        return TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("build_aur_pkgbuild.py")
    }

    private func runScript(arguments: [String]) throws -> (exitCode: Int32, output: String) {
        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", scriptURL().path] + arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? "<unreadable>"

        return (process.terminationStatus, output)
    }

    func test_scriptExists() throws {
        let fileManager = FileManager.default
        XCTAssertTrue(
            fileManager.fileExists(atPath: scriptURL().path),
            "build_aur_pkgbuild.py script must exist in Scripts/ directory"
        )
    }

    func test_generatesPkgbuildWithProvidedSources() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let outputPath = tempDir.appendingPathComponent("PKGBUILD")

        let (exitCode, output) = try runScript(arguments: [
            "--version", "v1.2.3",
            "--pkgrel", "2",
            "--x86_64-url", "https://example.com/docc2context-1.2.3-linux-x86_64.tar.gz",
            "--x86_64-sha256", "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
            "--aarch64-url", "https://example.com/docc2context-1.2.3-linux-aarch64.tar.gz",
            "--aarch64-sha256", "cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe",
            "--output", outputPath.path
        ])

        XCTAssertEqual(exitCode, 0, "Script should exit successfully: \(output)")
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: outputPath.path), "PKGBUILD should be created")

        let content = try String(contentsOf: outputPath, encoding: .utf8)

        XCTAssertTrue(content.contains("pkgver=1.2.3"), "Version should be normalized without leading 'v'")
        XCTAssertTrue(content.contains("pkgrel=2"), "pkgrel should be configurable")
        XCTAssertTrue(content.contains("arch=('x86_64' 'aarch64')"), "PKGBUILD must declare supported architectures")
        XCTAssertTrue(content.contains("source_x86_64=('https://example.com/docc2context-1.2.3-linux-x86_64.tar.gz')"),
                      "x86_64 source URL must be included")
        XCTAssertTrue(content.contains("sha256sums_x86_64=('deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef')"),
                      "x86_64 checksum must be included")
        XCTAssertTrue(content.contains("source_aarch64=('https://example.com/docc2context-1.2.3-linux-aarch64.tar.gz')"),
                      "aarch64 source URL must be included")
        XCTAssertTrue(content.contains("sha256sums_aarch64=('cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe')"),
                      "aarch64 checksum must be included")
        XCTAssertTrue(content.contains("docc2context-v${pkgver}"), "Staged directory must include versioned prefix")
        XCTAssertTrue(content.contains("/usr/local/bin/docc2context"), "Binary install path must be defined")
        XCTAssertTrue(content.contains("/usr/share/doc/docc2context/README.md"), "README install path must be defined")
        XCTAssertTrue(content.contains("/usr/share/doc/docc2context/LICENSE"), "LICENSE install path must be defined")
    }

    func test_missingRequiredArgumentsFails() throws {
        let (exitCode, output) = try runScript(arguments: ["--version", "0.0.1"])
        XCTAssertNotEqual(exitCode, 0, "Script should fail when required args are missing")
        XCTAssertTrue(output.lowercased().contains("required"), "Output should mention missing required arguments")
    }
}
