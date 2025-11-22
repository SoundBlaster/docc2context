# docc2context [VERSION]

## What's Changed

<!-- Describe the changes in this release -->

- Feature: [Description]
- Fix: [Description]
- Enhancement: [Description]

**Full Changelog**: https://github.com/SoundBlaster/docc2context/compare/[PREVIOUS_VERSION]...[VERSION]

---

## Installation

### Homebrew (macOS) - Recommended

The Homebrew formula has been automatically updated with this release:

```bash
brew tap SoundBlaster/tap
brew install docc2context
```

Or update an existing installation:

```bash
brew upgrade docc2context
```

Verify installation:

```bash
docc2context --version
# Should output: [VERSION]
```

### Manual Installation (Linux & macOS)

#### macOS

**arm64 (Apple Silicon):**
```bash
curl -L -O https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION]-macos-arm64.zip
unzip docc2context-[VERSION]-macos-arm64.zip
sudo mv docc2context-[VERSION]/docc2context /usr/local/bin/
```

**x86_64 (Intel):**
```bash
curl -L -O https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION]-macos-x86_64.zip
unzip docc2context-[VERSION]-macos-x86_64.zip
sudo mv docc2context-[VERSION]/docc2context /usr/local/bin/
```

#### Linux

**Debian/Ubuntu (.deb):**
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION]-linux-x86_64.deb
sudo dpkg -i docc2context-[VERSION]-linux-x86_64.deb
```

**RHEL/Fedora/CentOS (.rpm):**
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION]-linux-x86_64.rpm
sudo rpm -i docc2context-[VERSION]-linux-x86_64.rpm
```

**Generic tarball:**
```bash
curl -L https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION]-linux-x86_64.tar.gz | tar -xz
sudo mv docc2context-[VERSION]/docc2context /usr/local/bin/
```

---

## Checksums

All release artifacts include SHA256 checksums (`.sha256` files). Verify downloads:

```bash
# macOS
shasum -a 256 -c docc2context-[VERSION]-macos-arm64.zip.sha256

# Linux
sha256sum -c docc2context-[VERSION]-linux-x86_64.tar.gz.sha256
```

---

## Release Verification

This release has passed all quality gates:

- ✅ All tests passed (swift test)
- ✅ Coverage threshold met (>90%)
- ✅ Determinism verified (repeated builds produce identical outputs)
- ✅ Fixtures validated (manifest checksums match)
- ✅ Documentation linted (Markdown validation passed)
- ✅ Homebrew formula published to tap

---

## Notes

- **Homebrew Tap:** The formula is automatically published to [SoundBlaster/homebrew-tap](https://github.com/SoundBlaster/homebrew-tap) as part of the release workflow.
- **Compatibility:** Requires Swift 6.0.3 or later for building from source.
- **Platforms:** Supports macOS (arm64, x86_64) and Linux (x86_64, aarch64).

---

## Questions or Issues?

If you encounter any issues with this release, please [open an issue](https://github.com/SoundBlaster/docc2context/issues/new).
