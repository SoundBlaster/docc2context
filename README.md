# docc2context

`docc2context` is a Swift command-line utility that converts DocC bundles and archives into deterministic Markdown chunks plus link graphs for LLM ingestion. The package currently contains a CLI target (`docc2context`), a reusable core library, and unit tests wired through Swift Package Manager.

## Development quick start

### 1. Install Swift

Swift 6.0.1 is the baseline toolchain for this repo. On macOS, install or select Xcode 16.4 (the version our CI pins) so the bundled Swift 6.0.1 SDK matches the GitHub runners. On Linux, download the Swift 6.0.1 release for Ubuntu 22.04 (or your distro) from [Swift.org](https://swift.org/download/).

For Ubuntu 22.04 the basic setup looks like:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y clang libicu-dev libatomic1 libcurl4-openssl-dev
# download & unpack Swift toolchain from swift.org, then add it to PATH
export PATH=/opt/swift/usr/bin:$PATH  # adjust for your install prefix
```

### 2. Validate the toolchain

Confirm Swift is discoverable and matches the expected version:

```bash
swift --version
# should contain "6.0.1"
```

### 3. Build & test locally

Use SwiftPM for everyday workflows:

```bash
swift build
swift test
```

The tests exercise the CLI target and keep the Linux/macOS builds honest.

## Continuous Integration

GitHub Actions runs `swift build` and `swift test` on Ubuntu 22.04 and macOS. The Linux job relies on [`SwiftyLab/setup-swift`](https://github.com/SwiftyLab/setup-swift) to install Swift 6.0.1 and mirrors the package dependencies called out above so local and CI environments stay aligned. The macOS job selects Xcode 16.4 and uses its bundled Swift 6.0.1 toolchain to avoid mismatched SDK headers.

## Next steps

Active task **A1** tracks the ongoing bootstrap of the CLI, shared library, and CI skeleton. See [`DOCS/INPROGRESS/A1_bootstrap_swiftpm_ci.md`](DOCS/INPROGRESS/A1_bootstrap_swiftpm_ci.md) for the latest execution notes.
