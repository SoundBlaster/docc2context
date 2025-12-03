import Foundation
import XCTest

final class MacInstallScriptTests: XCTestCase {
    func test_installScriptDryRunPrintsPlannedOperations() throws {
        #if !os(macOS)
        throw XCTSkip("macOS install script is only validated on macOS hosts")
        #else

        let fileManager = FileManager.default
        let scriptURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("install_macos.sh")
        XCTAssertTrue(fileManager.isExecutableFile(atPath: scriptURL.path), "install_macos.sh must be executable")

        let tempRoot = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("install-script-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempRoot) }

        let prefix = tempRoot.appendingPathComponent("prefix", isDirectory: true)
        let downloadDir = tempRoot.appendingPathComponent("downloads", isDirectory: true)

        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = scriptURL
        process.arguments = [
            "--version", "v9.9.9",
            "--arch", "arm64",
            "--base-url", "https://example.invalid/downloads",
            "--download-dir", downloadDir.path,
            "--prefix", prefix.path,
            "--dry-run"
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationStatus == 0 else {
            let output = String(data: outputData, encoding: .utf8) ?? "<unreadable>"
            XCTFail("install_macos.sh failed: \(output)")
            return
        }

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let expectedArtifact = "docc2context-v9.9.9-macos-arm64.zip"
        XCTAssertTrue(output.contains("https://example.invalid/downloads/v9.9.9/\(expectedArtifact)"))
        XCTAssertTrue(output.contains(expectedArtifact + ".sha256"))
        XCTAssertTrue(output.contains(prefix.appendingPathComponent("bin/docc2context").path))
        XCTAssertTrue(output.lowercased().contains("dry run"), "Dry-run execution should be reported")
        #endif
    }
}
