# Swift Development Environment Setup

## Purpose
Ensure Swift toolchain is available and properly configured before running `swift build` or `swift test` commands during docc2context development and CI/CD workflows.

## Quick Check

Before starting any implementation task, verify Swift is installed:

```bash
swift --version
```

If command not found, follow the installation steps below.

## Installation Steps (Ubuntu 24.04 LTS)

### Step 1: Install System Dependencies

```bash
apt-get update
apt-get install -y \
    binutils \
    git \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-9-dev \
    libpython3.8 \
    libsqlite3-0 \
    libstdc++-9-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    unzip \
    zlib1g-dev
```

**Note:** These are standard system libraries required by Swift 6.0.3. Package names may vary for different Ubuntu versions.

### Step 2: Download Swift 6.0.3

```bash
cd /tmp
wget https://download.swift.org/swift-6.0.3-release/ubuntu2404/swift-6.0.3-RELEASE/swift-6.0.3-RELEASE-ubuntu24.04.tar.gz
```

**URL Mapping by Ubuntu Version:**
- Ubuntu 24.04: `https://download.swift.org/swift-6.0.3-release/ubuntu2404/...`
- Ubuntu 22.04: `https://download.swift.org/swift-6.0.3-release/ubuntu2204/...`
- Ubuntu 20.04: `https://download.swift.org/swift-6.0.3-release/ubuntu2004/...`

### Step 3: Extract and Install

```bash
tar -xzf swift-6.0.3-RELEASE-ubuntu24.04.tar.gz
mv swift-6.0.3-RELEASE-ubuntu24.04 /usr/local/swift
```

### Step 4: Add to PATH

```bash
export PATH="/usr/local/swift/usr/bin:$PATH"
swift --version
```

**Expected Output:**
```
Swift version 6.0.3 (swift-6.0.3-RELEASE)
Target: x86_64-unknown-linux-gnu
```

### Step 5: Persistent PATH Configuration (Optional)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="/usr/local/swift/usr/bin:$PATH"
```

Then reload:
```bash
source ~/.bashrc
```

## Automated Setup Script

Use this bash snippet to auto-detect and install Swift if missing:

```bash
#!/bin/bash

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "[INFO] Swift not found. Installing Swift 6.0.3..."

    # Install dependencies
    apt-get update && apt-get install -y \
        binutils git gnupg2 libc6-dev libcurl4-openssl-dev libedit2 \
        libgcc-9-dev libpython3.8 libsqlite3-0 libstdc++-9-dev \
        libxml2-dev libz3-dev pkg-config tzdata unzip zlib1g-dev

    # Download and install Swift
    cd /tmp
    wget -q https://download.swift.org/swift-6.0.3-release/ubuntu2404/swift-6.0.3-RELEASE/swift-6.0.3-RELEASE-ubuntu24.04.tar.gz
    tar -xzf swift-6.0.3-RELEASE-ubuntu24.04.tar.gz
    mv swift-6.0.3-RELEASE-ubuntu24.04 /usr/local/swift

    # Add to PATH
    export PATH="/usr/local/swift/usr/bin:$PATH"
    echo "[INFO] Swift installation complete"
else
    echo "[INFO] Swift already installed: $(swift --version)"
fi

# Verify installation
swift --version
```

## Verification

After installation, verify everything works:

```bash
# Check Swift version
swift --version

# Build test project
swift build

# Run tests
swift test
```

## Environment Variables

For CI/CD or container-based workflows, set:

```bash
export PATH="/usr/local/swift/usr/bin:$PATH"
```

## Troubleshooting

### "swift: command not found"
- Verify installation: `ls -la /usr/local/swift/usr/bin/swift`
- Check PATH: `echo $PATH | grep swift`
- Re-add to PATH: `export PATH="/usr/local/swift/usr/bin:$PATH"`

### Library loading errors
- Install missing packages: `apt-get install libpython3.8 libcurl4 libxml2`
- Check linked libraries: `ldd /usr/local/swift/usr/bin/swift`

### Network issues during download
- Retry download with longer timeout
- Check internet connectivity
- Try alternate mirror if available

## Performance Notes

- Initial Swift build may take 3-5 minutes (dependency compilation)
- Subsequent builds are faster due to caching
- Full test suite typically runs in <1 second per 50 tests on modern hardware

## Version Pinning

For production CI/CD, pin to specific Swift version in scripts:

```bash
SWIFT_VERSION="6.0.3"
SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2404/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu24.04.tar.gz"
```

## Related Documentation

- [START.md](../COMMANDS/START.md) - Full implementation workflow
- [PRD/docc2context_prd.md](../PRD/docc2context_prd.md) - Project requirements
- Swift Official: https://swift.org/download/

## Last Updated

2025-11-17 - Swift 6.0.3 on Ubuntu 24.04 LTS (tested and verified)
