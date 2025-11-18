import XCTest
import Foundation

final class PackageReleaseScriptTests: XCTestCase {
    private func ensureDebugBinaryExists() throws -> URL {
        let fileManager = FileManager.default
        let binaryURL = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("debug", isDirectory: true)
            .appendingPathComponent("docc2context")
        if fileManager.fileExists(atPath: binaryURL.path) {
            return binaryURL
        }

        let buildProcess = Process()
        buildProcess.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        buildProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        buildProcess.arguments = ["swift", "build", "--product", "docc2context"]
        let pipe = Pipe()
        buildProcess.standardOutput = pipe
        buildProcess.standardError = pipe
        try buildProcess.run()
        buildProcess.waitUntilExit()
        if buildProcess.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("swift build --product docc2context failed: \(output)")
            return binaryURL
        }
        guard fileManager.fileExists(atPath: binaryURL.path) else {
            XCTFail("docc2context debug binary not found at \(binaryURL.path)")
            return binaryURL
        }
        return binaryURL
    }

    private func scriptURL() -> URL {
        return TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("package_release.sh")
    }

    func test_packageScriptProducesArtifactsInDryRunMode() throws {
        #if os(Linux) || os(macOS)
        #else
        throw XCTSkip("Release packaging script is only validated on Apple/Linux platforms")
        #endif

        let fileManager = FileManager.default
        let script = scriptURL()
        let scriptPath = script.path
        XCTAssertTrue(fileManager.isExecutableFile(atPath: scriptPath), "package_release.sh must be executable")

        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("package-script-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        let version = "v0.0.0-test"
        let debugBinary = try ensureDebugBinaryExists()
        let expectedArtifactName = "docc2context-v0.0.0-test-linux-dryrun.zip"
        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = script
        process.arguments = [
            "--version", version,
            "--platform", "linux",
            "--output", outputDirectory.path,
            "--dry-run"
        ]
        var environment = ProcessInfo.processInfo.environment
        environment["PACKAGE_RELEASE_SKIP_GATES"] = "1"
        environment["PACKAGE_RELEASE_BINARY_OVERRIDE"] = debugBinary.path
        environment["PACKAGE_RELEASE_BUILD_CONFIGURATION"] = "debug"
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            let output = String(data: outputData, encoding: .utf8) ?? "<unreadable>"
            XCTFail("package_release.sh failed: \(output)")
            return
        }

        let artifactURL = outputDirectory.appendingPathComponent(expectedArtifactName)
        XCTAssertTrue(fileManager.fileExists(atPath: artifactURL.path), "Expected artifact not found at \(artifactURL.path)")

        let checksumURL = URL(fileURLWithPath: artifactURL.path + ".sha256")
        XCTAssertTrue(fileManager.fileExists(atPath: checksumURL.path), "Checksum file missing")

        let checksumContents = try String(contentsOf: checksumURL, encoding: .utf8)
        XCTAssertTrue(checksumContents.contains(expectedArtifactName), "Checksum output should reference the artifact name")

        let summaryURL = outputDirectory.appendingPathComponent("docc2context-v0.0.0-test-linux-dryrun.md")
        XCTAssertTrue(fileManager.fileExists(atPath: summaryURL.path), "Summary file missing")
        let summaryContents = try String(contentsOf: summaryURL, encoding: .utf8)
        XCTAssertTrue(summaryContents.contains("Version: 0.0.0-test"))
        XCTAssertTrue(summaryContents.contains("Platform: linux"))
        XCTAssertTrue(summaryContents.contains("Dry Run: true"))
    }
}
