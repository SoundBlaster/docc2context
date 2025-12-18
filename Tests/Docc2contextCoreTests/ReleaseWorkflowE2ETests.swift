import XCTest
import Foundation

/// E4 E2E Release Simulation Tests
///
/// Validates the complete release workflow end-to-end:
/// - Local dry-run simulation produces expected artifacts
/// - Artifact naming conventions match documentation
/// - All platform/architecture combinations are validated
/// - Homebrew formula generation produces valid Ruby syntax
/// - README installation instructions match actual artifacts
final class ReleaseWorkflowE2ETests: XCTestCase {

    // MARK: - Helper Methods

    private func scriptURL(name: String) -> URL {
        return TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("Scripts", isDirectory: true)
            .appendingPathComponent(name)
    }

    private func commandExists(_ name: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["which", name]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return false
        }
        return process.terminationStatus == 0
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
        case "x86_64", "amd64":
            return "x86_64"
        case "aarch64", "arm64":
            return "aarch64"
        default:
            XCTFail("Unexpected host architecture: \(raw). Update normalizedTarballArch to map this value.")
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
        case "x86_64", "amd64":
            return "x86_64"
        case "arm64", "aarch64":
            return "aarch64"
        default:
            XCTFail("Unexpected host architecture for RPM: \(raw)")
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

    // MARK: - Test: Linux Artifact Naming Conventions

    /// Validates that Linux artifacts follow the naming conventions documented in `DOCS/TASK_ARCHIVE/29_E4_E2EReleaseSim/E4_E2EReleaseSim.md`:
    /// - Tarballs: no 'v' prefix (e.g., docc2context-0.1.0-test-linux-x86_64.tar.gz)
    /// - Debian: includes '_linux_' (e.g., docc2context_0.1.0-test_linux_amd64.deb)
    /// - RPM: includes '-linux-' (e.g., docc2context-0.1.0-test-linux-x86_64.rpm)
    func test_linuxArtifactsFollowDocumentedNamingConventions() throws {
        #if os(Linux)
        guard commandExists("dpkg-deb") else {
            throw XCTSkip("dpkg-deb is required for Linux packaging validation")
        }

        guard commandExists("rpmbuild") else {
            throw XCTSkip("rpmbuild is required for Linux packaging validation")
        }

        let fileManager = FileManager.default
        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("e2e-release-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        let version = "v0.1.0-test"
        let debugBinary = try ensureDebugBinaryExists()

        // Test only host architecture (following PackageReleaseScriptTests pattern)
        let hostArch = try hostArchitecture()
        let tarballArch = normalizedTarballArch(for: hostArch)
        let debArchName = debArch(for: hostArch)
        let rpmArchName = rpmArch(for: hostArch)

        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = scriptURL(name: "package_release.sh")
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

        if process.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("package_release.sh failed: \(output)")
            return
        }

        // Validate tarball naming: NO 'v' prefix
        let expectedTarball = "docc2context-0.1.0-test-linux-\(tarballArch)-dryrun.tar.gz"
        let tarballURL = outputDirectory.appendingPathComponent(expectedTarball)
        XCTAssertTrue(fileManager.fileExists(atPath: tarballURL.path),
                     "Linux tarball must NOT include 'v' prefix: expected \(expectedTarball)")
        XCTAssertTrue(fileManager.fileExists(atPath: tarballURL.path + ".sha256"),
                     "Tarball checksum missing")

        // Validate Debian naming: includes '_linux_'
        let expectedDeb = "docc2context_0.1.0-test_linux_\(debArchName)-dryrun.deb"
        let debURL = outputDirectory.appendingPathComponent(expectedDeb)
        XCTAssertTrue(fileManager.fileExists(atPath: debURL.path),
                     "Debian package must include '_linux_': expected \(expectedDeb)")
        XCTAssertTrue(fileManager.fileExists(atPath: debURL.path + ".sha256"),
                     "Debian checksum missing")

        // Validate RPM naming: includes '-linux-'
        let expectedRpm = "docc2context-0.1.0-test-linux-\(rpmArchName)-dryrun.rpm"
        let rpmURL = outputDirectory.appendingPathComponent(expectedRpm)
        XCTAssertTrue(fileManager.fileExists(atPath: rpmURL.path),
                     "RPM package must include '-linux-': expected \(expectedRpm)")
        XCTAssertTrue(fileManager.fileExists(atPath: rpmURL.path + ".sha256"),
                     "RPM checksum missing")
        #else
        throw XCTSkip("Linux artifact validation only runs on Linux hosts")
        #endif
    }

    // MARK: - Test: macOS Artifact Naming Conventions

    /// Validates that macOS artifacts follow the naming conventions documented in `DOCS/TASK_ARCHIVE/29_E4_E2EReleaseSim/E4_E2EReleaseSim.md`:
    /// - Zips: includes 'v' prefix (e.g., docc2context-v0.1.0-test-macos-arm64.zip)
    func test_macOSArtifactsFollowDocumentedNamingConventions() throws {
        #if os(macOS)
        let fileManager = FileManager.default
        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("e2e-release-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        let version = "v0.1.0-test"
        let debugBinary = try ensureDebugBinaryExists()

        // Test only host architecture (following PackageReleaseScriptTests pattern)
        let hostArch = try hostArchitecture()

        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = scriptURL(name: "package_release.sh")
        process.arguments = [
            "--version", version,
            "--platform", "macos",
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

        if process.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("package_release.sh failed: \(output)")
            return
        }

        // Validate macOS zip naming: INCLUDES 'v' prefix
        let expectedZip = "docc2context-v0.1.0-test-macos-\(hostArch)-dryrun.zip"
        let zipURL = outputDirectory.appendingPathComponent(expectedZip)
        XCTAssertTrue(fileManager.fileExists(atPath: zipURL.path),
                     "macOS zip must include 'v' prefix: expected \(expectedZip)")
        XCTAssertTrue(fileManager.fileExists(atPath: zipURL.path + ".sha256"),
                     "macOS zip checksum missing")
        #else
        throw XCTSkip("macOS artifact validation only runs on macOS hosts")
        #endif
    }

    // MARK: - Test: Homebrew Formula Validation

    /// Validates that Homebrew formula generation produces valid Ruby syntax and can be parsed
    func test_homebrewFormulaGenerationProducesValidRubySyntax() throws {
        guard commandExists("ruby") else {
            throw XCTSkip("ruby is required for Homebrew formula syntax validation")
        }

        let fileManager = FileManager.default
        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("e2e-release-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        // Generate formula using the build_homebrew_formula.py script
        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "python3",
            scriptURL(name: "build_homebrew_formula.py").path,
            "--version", "0.1.0-test",
            "--arm64-url", "https://example.com/docc2context-v0.1.0-test-macos-arm64.zip",
            "--arm64-sha256", "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef",
            "--x86_64-url", "https://example.com/docc2context-v0.1.0-test-macos-x86_64.zip",
            "--x86_64-sha256", "cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe",
            "--output", outputDirectory.appendingPathComponent("docc2context.rb").path
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("Formula generation failed: \(output)")
            return
        }

        let formulaPath = outputDirectory.appendingPathComponent("docc2context.rb")
        XCTAssertTrue(fileManager.fileExists(atPath: formulaPath.path), "Formula file not generated")

        // Validate Ruby syntax using ruby -c
        let validateProcess = Process()
        validateProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        validateProcess.arguments = ["ruby", "-c", formulaPath.path]
        let validatePipe = Pipe()
        validateProcess.standardOutput = validatePipe
        validateProcess.standardError = validatePipe
        try validateProcess.run()
        validateProcess.waitUntilExit()

        if validateProcess.terminationStatus != 0 {
            let output = String(data: validatePipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("Formula Ruby syntax validation failed: \(output)")
            return
        }

        // Verify formula contains expected content
        let formulaContent = try String(contentsOf: formulaPath, encoding: .utf8)
        XCTAssertTrue(formulaContent.contains("class Docc2context < Formula"),
                     "Formula must define Docc2context class")
        XCTAssertTrue(formulaContent.contains("desc \""),
                     "Formula must include description")
        XCTAssertTrue(formulaContent.contains("homepage \""),
                     "Formula must include homepage")
        XCTAssertTrue(formulaContent.contains("version \"0.1.0-test\""),
                     "Formula must include correct version")
        XCTAssertTrue(formulaContent.contains("on_arm do"),
                     "Formula must include arm64 architecture block")
        XCTAssertTrue(formulaContent.contains("on_intel do"),
                     "Formula must include x86_64 architecture block")
    }

    // MARK: - Test: README Installation Instructions Match Artifacts

    /// Validates that README installation instructions reference artifact names that match
    /// the actual artifacts produced by the release scripts
    func test_readmeInstallationInstructionsMatchActualArtifacts() throws {
        let fileManager = FileManager.default
        let docsPath = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent("DOCS", isDirectory: true)
            .appendingPathComponent("README", isDirectory: true)
            .appendingPathComponent("releases.md", isDirectory: false)

        XCTAssertTrue(fileManager.fileExists(atPath: docsPath.path), "Release docs must exist")

        let readmeContent = try String(contentsOf: docsPath, encoding: .utf8)

        // Verify README mentions Linux tarball format (without 'v' prefix)
        XCTAssertTrue(readmeContent.contains("docc2context-") && readmeContent.contains("-linux-"),
                     "README must document Linux tarball naming convention")

        // Verify README mentions Debian package format (with '_linux_')
        XCTAssertTrue(readmeContent.contains("docc2context_") && readmeContent.contains("_linux_"),
                     "README must document Debian package naming convention")

        // Verify README mentions macOS zip format (with 'v' prefix)
        XCTAssertTrue(readmeContent.contains("docc2context-v") && readmeContent.contains("-macos-"),
                     "README must document macOS zip naming convention")

        // Verify README includes Homebrew installation instructions
        XCTAssertTrue(readmeContent.contains("brew install") || readmeContent.contains("Homebrew"),
                     "README must include Homebrew installation instructions")
    }

    // MARK: - Test: Release Template Documents musl Artifacts

    /// Validates that the GitHub release template includes instructions for downloading
    /// musl (universal) Linux artifacts alongside glibc builds. This ensures release notes
    /// remain aligned with the musl packaging workflow introduced for H2.
    func test_releaseTemplateDocumentsMuslArtifacts() throws {
        let fileManager = FileManager.default
        let templatePath = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".github", isDirectory: true)
            .appendingPathComponent("RELEASE_TEMPLATE.md")

        XCTAssertTrue(fileManager.fileExists(atPath: templatePath.path), "Release template must exist")

        let template = try String(contentsOf: templatePath, encoding: .utf8)

        XCTAssertTrue(template.localizedCaseInsensitiveContains("musl"),
                      "Release template must mention musl / universal Linux artifacts")
        XCTAssertTrue(template.contains("linux-x86_64-musl"),
                      "Release template must include musl tarball example")
        XCTAssertTrue(template.contains("linux_amd64-musl"),
                      "Release template must include musl Debian package example")
        XCTAssertTrue(template.contains("linux-x86_64-musl.rpm"),
                      "Release template must include musl RPM example")
    }

    // MARK: - Test: Release Gates Pass Before Packaging

    /// Validates that release gates script exists and is executable.
    /// NOTE: We do NOT run release_gates.sh here as it would recursively invoke swift test,
    /// creating an infinite loop. The actual gates enforcement is validated by running
    /// package_release.sh without PACKAGE_RELEASE_SKIP_GATES=1 in other tests.
    func test_releaseGatesMustPassBeforePackaging() throws {
        let fileManager = FileManager.default
        let gatesScript = scriptURL(name: "release_gates.sh")

        XCTAssertTrue(fileManager.fileExists(atPath: gatesScript.path),
                     "release_gates.sh must exist")
        XCTAssertTrue(fileManager.isExecutableFile(atPath: gatesScript.path),
                     "release_gates.sh must be executable")

        // Verify release_gates.sh contains expected validation steps
        let scriptContent = try String(contentsOf: gatesScript, encoding: .utf8)
        XCTAssertTrue(scriptContent.contains("swift test"),
                     "release_gates.sh must run swift test")
        XCTAssertTrue(scriptContent.contains("TutorialCatalog") || scriptContent.contains("Fixtures"),
                     "release_gates.sh must reference test fixtures")
        XCTAssertTrue(scriptContent.contains("determinism") && scriptContent.contains("hash"),
                     "release_gates.sh must check determinism with hash validation")
    }

    // MARK: - Test: Artifact Checksums Are Valid

    /// Validates that all artifacts produce valid SHA256 checksums
    func test_artifactChecksumsAreValid() throws {
        #if os(Linux) || os(macOS)
        #else
        throw XCTSkip("Checksum validation only runs on Linux or macOS")
        #endif

        #if os(Linux)
        // On Linux, packaging requires dpkg-deb and rpmbuild
        guard commandExists("dpkg-deb") else {
            throw XCTSkip("dpkg-deb is required for Linux packaging validation")
        }
        guard commandExists("rpmbuild") else {
            throw XCTSkip("rpmbuild is required for Linux packaging validation")
        }
        #endif

        let fileManager = FileManager.default
        let outputDirectory = TestSupportPaths.repositoryRootDirectory
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("e2e-release-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: outputDirectory) }

        let version = "v0.1.0-test"
        let debugBinary = try ensureDebugBinaryExists()
        let hostArch = try hostArchitecture()

        // Generate a single artifact to test checksum validation
        let process = Process()
        process.currentDirectoryURL = TestSupportPaths.repositoryRootDirectory
        process.executableURL = scriptURL(name: "package_release.sh")

        #if os(Linux)
        let platform = "linux"
        let tarballArch = normalizedTarballArch(for: hostArch)
        let expectedArtifact = "docc2context-0.1.0-test-linux-\(tarballArch)-dryrun.tar.gz"
        #elseif os(macOS)
        let platform = "macos"
        let expectedArtifact = "docc2context-v0.1.0-test-macos-\(hostArch)-dryrun.zip"
        #else
        throw XCTSkip("Unsupported platform")
        #endif

        process.arguments = [
            "--version", version,
            "--platform", platform,
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

        if process.terminationStatus != 0 {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "<unreadable>"
            XCTFail("package_release.sh failed: \(output)")
            return
        }

        let artifactURL = outputDirectory.appendingPathComponent(expectedArtifact)
        let checksumURL = URL(fileURLWithPath: artifactURL.path + ".sha256")

        XCTAssertTrue(fileManager.fileExists(atPath: artifactURL.path), "Artifact must exist")
        XCTAssertTrue(fileManager.fileExists(atPath: checksumURL.path), "Checksum file must exist")

        // Validate checksum format (should be 64 hex characters + filename)
        let checksumContent = try String(contentsOf: checksumURL, encoding: .utf8)
        let checksumPattern = "^[0-9a-f]{64}\\s+\\S+$"
        let regex = try NSRegularExpression(pattern: checksumPattern, options: [])
        let range = NSRange(checksumContent.startIndex..<checksumContent.endIndex, in: checksumContent)
        XCTAssertNotNil(regex.firstMatch(in: checksumContent, options: [], range: range),
                       "Checksum file must contain valid SHA256 hash (64 hex chars) + filename")
    }
}
