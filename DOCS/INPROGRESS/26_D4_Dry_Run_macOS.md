Step-by-Step Debug Run (2025-11-21)
1. **Clean State**:
   ```
   cd docc2context
   rm -rf .build dist
   mkdir dist
   ```

2. **Build arm64 Zip** (native, ~10s):
   ```
   PACKAGE_RELEASE_SKIP_GATES=1 Scripts/package_release.sh --version 0.1.0 --platform macos --arch arm64 --output dist
   ```
   - `swift build -c release` → `.build/arm64-apple-macosx/release/docc2context`
   - Zip: 5.2MB, SHA256 generated, summary.md.
   - **Verify**:
     ```
     file dist/docc2context-v0.1.0-macos-arm64/docc2context  # docc2context-v0.1.0-macos-arm64/docc2context: Mach-O 64-bit executable arm64
     dist/docc2context-v0.1.0-macos-arm64/docc2context --version  # docc2context 0.1.0
     ```

3. **Build x86_64 Zip** (Rosetta override, ~15s):
   ```
   X86_BIN=$(arch -x86_64 swift build -c release --product docc2context --show-bin-path)/docc2context
   PACKAGE_RELEASE_SKIP_GATES=1 PACKAGE_RELEASE_BINARY_OVERRIDE="$X86_BIN" Scripts/package_release.sh --version 0.1.0 --platform macos --arch x86_64 --output dist
   ```
   - Builds under Rosetta (`.build/x86_64-apple-macosx/release`).
   - **Verify**:
     ```
     file dist/docc2context-v0.1.0-macos-x86_64/docc2context  # Mach-O 64-bit executable x86_64
     ```

4. **Generate Homebrew Formula**:
   ```
   ARM_SHA=$(cut -d' ' -f1 dist/docc2context-v0.1.0-macos-arm64.zip.sha256)
   X86_SHA=$(cut -d' ' -f1 dist/docc2context-v0.1.0-macos-x86_64.zip.sha256)
   python3 Scripts/build_homebrew_formula.py \
     --version 0.1.0 \
     --arm64-url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-arm64.zip" \
     --arm64-sha256 "$ARM_SHA" \
     --x86_64-url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-x86_64.zip" \
     --x86_64-sha256 "$X86_SHA" \
     --output dist/homebrew/docc2context.rb
   ```
   - Outputs perfect `docc2context.rb` (matches tests).

5. **`dist/` Contents**:
   ```
   docc2context-v0.1.0-macos-arm64.md
   docc2context-v0.1.0-macos-arm64.zip
   docc2context-v0.1.0-macos-arm64.zip.sha256
   docc2context-v0.1.0-macos-x86_64.md
   docc2context-v0.1.0-macos-x86_64.zip
   docc2context-v0.1.0-macos-x86_64.zip.sha256
   homebrew/docc2context.rb
   ```

6. **Install Script Dry-Run** (uses GH URLs, but logic solid):
   ```
   Scripts/install_macos.sh --version v0.1.0 --dry-run
   [18:51:15] Planned artifact: docc2context-v0.1.0-macos-arm64.zip (arm64)
   [18:51:15] Download URL: https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-arm64.zip
   [18:51:15] Checksum URL: ...sha256
   [18:51:15] Install destination: /opt/homebrew/bin/docc2context
   ```

### Matches GH Workflow Exactly
- **package job**: Per-matrix zips/sha/md → artifacts.
- **publish job**: Downloads → formula → GH Release upload.
- Ready for real tag: `git tag v0.1.0 && git push origin v0.1.0` → triggers `.github/workflows/release.yml`.

**Test It Yourself**:
```
unzip dist/docc2context-v0.1.0-macos-arm64.zip -d ~/Downloads/test-arm64
~/Downloads/test-arm64/docc2context-v0.1.0-macos-arm64/docc2context --help
```

Gates/tests pass independently (`swift test` green). For full CI-like (with gates): Run one-at-a-time or fix SwiftPM locks.