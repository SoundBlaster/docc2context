import Foundation
import XCTest

final class CloudsmithPublishScriptTests: XCTestCase {
    private func scriptURL() -> URL {
        return TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent("publish_to_cloudsmith.sh")
    }

    private func runScript(arguments: [String], environment: [String: String] = [:]) throws -> (exitCode: Int32, output: String) {
        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptURL().path] + arguments

        var env = ProcessInfo.processInfo.environment
        environment.forEach { env[$0.key] = $0.value }
        process.environment = env

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? "<unreadable>"
        return (process.terminationStatus, output)
    }

    func test_scriptExists() {
        let fileManager = FileManager.default
        XCTAssertTrue(
            fileManager.fileExists(atPath: scriptURL().path),
            "publish_to_cloudsmith.sh must exist in Scripts/"
        )
    }

    func test_dryRunSummarizesUploads() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let debPath = tempDir.appendingPathComponent("docc2context_1.2.3_linux_amd64.deb")
        let rpmPath = tempDir.appendingPathComponent("docc2context-1.2.3-linux-x86_64.rpm")
        XCTAssertTrue(FileManager.default.createFile(atPath: debPath.path, contents: Data("deb".utf8)))
        XCTAssertTrue(FileManager.default.createFile(atPath: rpmPath.path, contents: Data("rpm".utf8)))

        let (exitCode, output) = try runScript(
            arguments: [
                "--owner", "soundblaster",
                "--repository", "docc2context",
                "--version", "v1.2.3",
                "--artifact-dir", tempDir.path,
                "--apt-distribution", "ubuntu",
                "--apt-release", "jammy",
                "--rpm-distribution", "centos",
                "--rpm-release", "7",
                "--dry-run"
            ],
            environment: ["CLOUDSMITH_API_KEY": "dummy-key"]
        )

        XCTAssertEqual(exitCode, 0, "Dry-run should succeed")
        XCTAssertTrue(output.contains("cloudsmith push deb soundblaster/docc2context"), "Dry-run should outline deb upload")
        XCTAssertTrue(output.contains("cloudsmith push rpm soundblaster/docc2context"), "Dry-run should outline rpm upload")
        XCTAssertTrue(output.contains("1.2.3"), "Version should be normalized without leading 'v'")
        XCTAssertTrue(output.contains("ubuntu/jammy"), "APT distribution/release should be echoed")
        XCTAssertTrue(output.contains("centos/7"), "RPM distribution/release should be echoed")
    }

    func test_missingOwnerValueShowsHelpfulError() throws {
        let (exitCode, output) = try runScript(arguments: ["--owner"])

        XCTAssertNotEqual(exitCode, 0, "Missing owner value should fail")
        XCTAssertTrue(output.contains("--owner requires a value"))
    }

    func test_failsWhenArtifactsMissing() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let (exitCode, output) = try runScript(
            arguments: [
                "--owner", "soundblaster",
                "--repository", "docc2context",
                "--version", "v0.0.1",
                "--artifact-dir", tempDir.path,
                "--dry-run"
            ]
        )

        XCTAssertNotEqual(exitCode, 0, "Script should fail when no artifacts are present")
        XCTAssertTrue(output.lowercased().contains("deb"), "Error output should mention missing deb packages")
        XCTAssertTrue(output.lowercased().contains("rpm"), "Error output should mention missing rpm packages")
    }

    func test_dryRunSkipsMuslVariantArtifactsByDefault() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let glibcDebPath = tempDir.appendingPathComponent("docc2context_1.2.3_linux_amd64.deb")
        let muslDebPath = tempDir.appendingPathComponent("docc2context_1.2.3_linux_amd64-musl.deb")
        let glibcRpmPath = tempDir.appendingPathComponent("docc2context-1.2.3-linux-x86_64.rpm")
        let muslRpmPath = tempDir.appendingPathComponent("docc2context-1.2.3-linux-x86_64-musl.rpm")

        XCTAssertTrue(FileManager.default.createFile(atPath: glibcDebPath.path, contents: Data("deb".utf8)))
        XCTAssertTrue(FileManager.default.createFile(atPath: muslDebPath.path, contents: Data("deb".utf8)))
        XCTAssertTrue(FileManager.default.createFile(atPath: glibcRpmPath.path, contents: Data("rpm".utf8)))
        XCTAssertTrue(FileManager.default.createFile(atPath: muslRpmPath.path, contents: Data("rpm".utf8)))

        let (exitCode, output) = try runScript(
            arguments: [
                "--owner", "soundblaster",
                "--repository", "docc2context",
                "--version", "v1.2.3",
                "--artifact-dir", tempDir.path,
                "--dry-run"
            ],
            environment: ["CLOUDSMITH_API_KEY": "dummy-key"]
        )

        XCTAssertEqual(exitCode, 0, "Dry-run should succeed")
        XCTAssertTrue(output.contains("Skipping 1 variant package(s)"), "Dry-run should warn about skipped variants")
        XCTAssertTrue(output.contains(glibcDebPath.path), "Dry-run should include glibc deb upload")
        XCTAssertFalse(
            output.contains("cloudsmith push deb soundblaster/docc2context \"\(muslDebPath.path)\""),
            "Dry-run should exclude musl deb upload by default"
        )
        XCTAssertTrue(output.contains(glibcRpmPath.path), "Dry-run should include glibc rpm upload")
        XCTAssertFalse(
            output.contains("cloudsmith push rpm soundblaster/docc2context \"\(muslRpmPath.path)\""),
            "Dry-run should exclude musl rpm upload by default"
        )
    }
}
