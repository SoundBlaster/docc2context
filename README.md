# docc2context

`docc2context` is a Swift command-line utility that converts DocC bundles and archives into deterministic Markdown chunks plus link graphs for LLM ingestion. The package currently contains a CLI target (`docc2context`), a reusable core library, and unit tests wired through Swift Package Manager.

## Development quick start

### 1. Install Swift

Swift 5.9+ is required. On macOS, install or select Xcode 16.4 (the version our CI pins) so the bundled toolchain matches the GitHub runners. On Linux, follow the official [Swift.org downloads](https://swift.org/download/) for your distribution.

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
```

### 3. Build & test locally

Use SwiftPM for everyday workflows:

```bash
swift build
swift test
```

The tests exercise the CLI target and keep the Linux/macOS builds honest.

## Continuous Integration

GitHub Actions runs `swift build` and `swift test` on Ubuntu 22.04 and macOS. The Linux job relies on [`SwiftyLab/setup-swift`](https://github.com/SwiftyLab/setup-swift) to install Swift and mirrors the package dependencies called out above so local and CI environments stay aligned.

## Next steps

Active task **A1** tracks the ongoing bootstrap of the CLI, shared library, and CI skeleton. See [`DOCS/INPROGRESS/A1_bootstrap_swiftpm_ci.md`](DOCS/INPROGRESS/A1_bootstrap_swiftpm_ci.md) for the latest execution notes.
