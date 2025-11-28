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

> Replace `[VERSION]` with the tag (e.g., `v1.2.3`) and `[VERSION_NO_PREFIX]` with the numeric version (e.g., `1.2.3`).

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

_glibc (default):_
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context_[VERSION_NO_PREFIX]_linux_amd64.deb
sudo dpkg -i docc2context_[VERSION_NO_PREFIX]_linux_amd64.deb
```

_musl / universal (recommended for Alpine or glibc mismatches):_
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context_[VERSION_NO_PREFIX]_linux_amd64-musl.deb
sudo dpkg -i docc2context_[VERSION_NO_PREFIX]_linux_amd64-musl.deb
```

**RHEL/Fedora/CentOS (.rpm):**

_glibc (default):_
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION_NO_PREFIX]-linux-x86_64.rpm
sudo rpm -i docc2context-[VERSION_NO_PREFIX]-linux-x86_64.rpm
```

_musl / universal (recommended for Alpine or glibc mismatches):_
```bash
wget https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION_NO_PREFIX]-linux-x86_64-musl.rpm
sudo rpm -i docc2context-[VERSION_NO_PREFIX]-linux-x86_64-musl.rpm
```

**Generic tarball:**

_glibc (default):_
```bash
curl -L https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION_NO_PREFIX]-linux-x86_64.tar.gz | tar -xz
sudo mv docc2context-v[VERSION_NO_PREFIX]/docc2context /usr/local/bin/
```

_musl / universal (recommended for Alpine or glibc mismatches):_
```bash
curl -L https://github.com/SoundBlaster/docc2context/releases/download/[VERSION]/docc2context-[VERSION_NO_PREFIX]-linux-x86_64-musl.tar.gz | tar -xz
sudo mv docc2context-v[VERSION_NO_PREFIX]/docc2context /usr/local/bin/
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
- **Platforms:** Supports macOS (arm64, x86_64) and Linux (x86_64, aarch64) with both glibc and musl (universal) release assets.

---

## Questions or Issues?

If you encounter any issues with this release, please [open an issue](https://github.com/SoundBlaster/docc2context/issues/new).
