# Contributing

## Swift toolchain

Swift 6.1.2 is the baseline toolchain for this repo. On macOS, install or select Xcode 16.4 (the version our CI pins) so the bundled Swift 6.1.2 SDK matches the GitHub runners. On Linux, download the Swift 6.1.2 release for Ubuntu 22.04 (or your distro) from https://swift.org/download/.

For Ubuntu 22.04 the basic setup looks like:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y clang libicu-dev libatomic1 libcurl4-openssl-dev
# download & unpack Swift toolchain from swift.org, then add it to PATH
export PATH=/opt/swift/usr/bin:$PATH  # adjust for your install prefix
```

Confirm Swift is discoverable and matches the expected version:

```bash
swift --version
# should contain "6.1.2"
```

## Build & test

```bash
swift build
swift test
```

## Coverage

Phase D requires both the CLI and the core library to maintain at least 90% line coverage:

```bash
swift test --enable-code-coverage
python3 Scripts/enforce_coverage.py --threshold 90
```

## Markdown lint

```bash
python3 Scripts/lint_markdown.py
```

