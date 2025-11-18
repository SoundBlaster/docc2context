import XCTest
import Foundation

final class PackageReleaseScriptTests: XCTestCase {
    private func ensureCommandAvailable(_ command: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["which", command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            throw XCTSkip("Required command \(command) missing for packaging test: \(output)")
        }
    }

    private func hostArchitecture() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["uname", "-m"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            let output = String(data: data, encoding: .utf8) ?? "<unreadable>"
            throw XCTSkip("Unable to determine host architecture: \(output)")
        }
        guard let raw = String(data: data, encoding: .utf8) else {
            throw XCTSkip("Host architecture output unreadable")
        }
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedTarballArch(for raw: String) -> String {
        switch raw {
        case "amd64":
            return "x86_64"
        case "arm64":
            return "aarch64"
        default:
            return raw
        }
    }

    private func debArch(for raw: String) -> String {
        switch raw {
        case "x86_64", "amd64":
            return "amd64"
        case "arm64", "aarch64":
            return "arm64"
        default:
            return raw
        }
    }

    private func rpmArch(for raw: String) -> String {
        switch raw {
        case "amd64":
            return "x86_64"
        case "arm64":
            return "aarch64"
        default:
            return raw
        }
    }

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

        try ensureCommandAvailable("dpkg-deb")
        try ensureCommandAvailable("rpmbuild")

        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("package-script-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        let version = "v0.0.0-test"
        let debugBinary = try ensureDebugBinaryExists()
        let hostArch = try hostArchitecture()
        let tarballArch = normalizedTarballArch(for: hostArch)
        let debArchName = debArch(for: hostArch)
        let rpmArchName = rpmArch(for: hostArch)
        let expectedTarball = "docc2context-0.0.0-test-linux-\(tarballArch)-dryrun.tar.gz"
        let expectedDeb = "docc2context_0.0.0-test_linux_\(debArchName)-dryrun.deb"
        let expectedRpm = "docc2context-0.0.0-test-linux-\(rpmArchName)-dryrun.rpm"
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

        let tarballURL = outputDirectory.appendingPathComponent(expectedTarball)
        XCTAssertTrue(fileManager.fileExists(atPath: tarballURL.path), "Tarball artifact missing")
        XCTAssertTrue(fileManager.fileExists(atPath: tarballURL.path + ".sha256"))

        let debURL = outputDirectory.appendingPathComponent(expectedDeb)
        XCTAssertTrue(fileManager.fileExists(atPath: debURL.path), "Debian package missing")
        XCTAssertTrue(fileManager.fileExists(atPath: debURL.path + ".sha256"))

        let rpmURL = outputDirectory.appendingPathComponent(expectedRpm)
        XCTAssertTrue(fileManager.fileExists(atPath: rpmURL.path), "RPM package missing")
        XCTAssertTrue(fileManager.fileExists(atPath: rpmURL.path + ".sha256"))

        let summaryName = "docc2context-v0.0.0-test-linux-\(hostArch)-dryrun.md"
        let summaryURL = outputDirectory.appendingPathComponent(summaryName)
        XCTAssertTrue(fileManager.fileExists(atPath: summaryURL.path), "Summary file missing")
        let summaryContents = try String(contentsOf: summaryURL, encoding: .utf8)
        XCTAssertTrue(summaryContents.contains("Version: 0.0.0-test"))
        XCTAssertTrue(summaryContents.contains("Platform: linux"))
        XCTAssertTrue(summaryContents.contains("Architecture: \(hostArch)"))
        XCTAssertTrue(summaryContents.contains("Dry Run: true"))
        XCTAssertTrue(summaryContents.contains(expectedTarball))
        XCTAssertTrue(summaryContents.contains(expectedDeb))
        XCTAssertTrue(summaryContents.contains(expectedRpm))
    }
}
