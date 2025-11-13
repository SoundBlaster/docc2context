# Swift CI Setup Manual

This guide captures the exact steps and configuration required to keep the GitHub
Actions workflows green for both Ubuntu and macOS runners. Follow it whenever you
need to audit or reproduce the Swift toolchain setup in CI.

## 1. Workflow Overview

- CI definition: `.github/workflows/ci.yml`.
- Jobs: `linux` (Ubuntu 22.04) and `macos` (macOS latest with Xcode 16.4).
- Swift toolchain baseline: **Swift 6.1.2** across all jobs.

## 2. Ubuntu Runner Setup

1. **Checkout repository**
   ```yaml
   - uses: actions/checkout@v4
   ```
2. **Install system dependencies**
   ```yaml
   - name: Install Swift dependencies
     run: |
       sudo apt-get update
       sudo apt-get install -y clang libicu-dev libatomic1 libcurl4-openssl-dev
   ```
   These packages satisfy Swift's libc, ICU, atomic, and libcurl requirements.
3. **Install Swift toolchain**
   ```yaml
   - name: Set up Swift ${{ matrix.swift }}
     uses: SwiftyLab/setup-swift@v1
     with:
       swift-version: ${{ matrix.swift }} # currently 6.1.2
   ```
4. **Verify the toolchain**
   ```yaml
   - name: Validate Swift toolchain
     run: |
       swift --version | tee swift-version.txt
       grep "${{ matrix.swift }}" swift-version.txt
   ```
5. **Build and test**
   ```yaml
   - name: Build
     run: swift build --build-tests
   - name: Run tests
     run: swift test --enable-test-discovery
   ```

## 3. macOS Runner Setup

1. **Checkout repository**
   ```yaml
   - uses: actions/checkout@v4
   ```
2. **Select Xcode 16.4**
   ```yaml
   - name: Select Xcode 16.4
     uses: maxim-lobanov/setup-xcode@v1
     with:
       xcode-version: '16.4'
   ```
   This ensures the runner exposes the macOS 15.5 SDK bundled with Swift 6.1.2.
3. **Validate Swift version**
   ```yaml
   - name: Validate Swift toolchain
     run: |
       swift --version | tee swift-version.txt
       grep "${{ matrix.swift }}" swift-version.txt
   ```
4. **Build and test**
   ```yaml
   - name: Build
     run: swift build --build-tests
   - name: Run tests
     run: swift test --enable-test-discovery
   ```

## 4. Matrix Configuration

Both jobs share a matrix with a single Swift version entry:
```yaml
strategy:
  matrix:
    swift: ['6.1.2']
```
Adjust this value when bumping the toolchain to keep the validation check in
sync.

## 5. Troubleshooting Checklist

- **Version mismatch**: update the matrix value and README guidance whenever the
  hosted runner moves to a newer Swift release.
- **Missing Linux dependencies**: rerun the `apt-get install` step locally to
  confirm package availability on Ubuntu 22.04.
- **macOS header issues**: ensure `setup-xcode` points at an available version
  listed in the workflow logs. Switching to an unsupported Xcode build causes
  `_stddef` or SDK import errors.
- **Caching**: the workflow currently skips caches to keep the setup deterministic.
  If build time becomes a concern, add `actions/cache` around `.build/` but keep
  the toolchain validation step untouched.

Keep this manual updated whenever the workflow changes so onboarding engineers
can reason about CI failures quickly.
