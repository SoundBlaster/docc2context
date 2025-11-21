# D4-MAC macOS Release Channels — SELECT_NEXT Planning (2025-11-19)

## Context & Drivers
- **PRD §4.6 / D4-MAC** requires Homebrew distribution, manual install guidance, and notarization/codesigning steps so macOS users can trust binaries without rebuilding from source. Linux (D4-LNX) and cross-platform release automation (D4) are archived, so this is the last open Phase D deliverable.
- The workplan lists D4-MAC as the sole remaining item in Phase D. `DOCS/todo.md` previously tracked it under “Under Consideration”; this SELECT_NEXT run promotes it into active planning per the command runbook.
- `Scripts/package_release.sh` already emits `docc2context-v<version>-macos.zip` archives and optionally codesigns binaries when `MACOS_SIGN_IDENTITY` is provided, but the artifacts are not architecture-qualified and there is no automation to generate/update a Homebrew formula.
- `README.md` only documents Linux installation paths (tarball, `.deb`, `.rpm`). macOS users lack instructions for Homebrew, manual install destinations (`/usr/local/bin` vs `/opt/homebrew/bin`), and notarization status.

## Acceptance Criteria Snapshot
1. **Homebrew Tap Coverage** — Maintain a tap/formula that references arm64 + x86_64 release artifacts. Formula includes `test do` invoking `docc2context --version` (per PRD §4.6 bullet 3). Automation regenerates the formula as part of release packaging, ideally via a helper script that injects URL + SHA256 for each architecture.
2. **Manual Install Path** — README + optional installer script guide direct installs from GitHub Releases with architecture-aware URLs, checksum verification, extraction, and placement into `/usr/local/bin` (Intel) or `/opt/homebrew/bin` (Apple Silicon). Provide a single-line bootstrapper similar to Linux curl/tar instructions.
3. **Codesign & Notarization Guidance** — Document exact `codesign`, `notarytool submit`, and `stapler staple` commands for the prebuilt macOS zips, clarifying when notarized artifacts are required (prebuilt bottles) vs optional (source builds via Homebrew). Capture prerequisites (Developer ID cert, App Store Connect API key) and where logs/artifacts live.
4. **Release Workflow Hooks** — `.github/workflows/release.yml` macOS job must produce both arm64 and x86_64 zips (even if x86_64 runs under Rosetta-cross compile) and upload Homebrew formula updates or instructions for manual tap publishing. Release summary markdown should include architecture metadata for macOS, mirroring Linux.
5. **Test/Doc Coverage** — Extend `PackageReleaseScriptTests` (or add new ones) to lock macOS artifact naming, codesign toggles, and summary output. Update `DocumentationGuidanceTests` snapshots as README gains new install content. Release gates should capture any new scripts (e.g., install helper) if they need linting or determinism checks.

## Current State Assessment
- `Scripts/package_release.sh` names macOS zips `docc2context-v<version>-macos.zip` without architecture suffix; PRD expects per-arch artifacts so the formula can reference deterministic downloads. Linux packaging uses `build_linux_packages.sh` to emit multi-format outputs; there is no macOS analogue beyond the zip.
- `.github/workflows/release.yml` currently builds a single macOS arm64 artifact (per README). There is no job to cross-build x86_64 or run `brew` smoke tests.
- `README.md` lines 120–210 cover Linux install commands only. macOS instructions are missing despite PRD calling for Homebrew/manual coverage.
- There is no `Scripts/homebrew` helper or tests ensuring the formula stays consistent with release metadata.

## Proposed Plan of Attack (for START phase)
1. **Artifact Naming & Release Script Enhancements**
   - Update `Scripts/package_release.sh` so `package_macos` accepts an `--arch` flag and emits `docc2context-v<version>-macos-<arch>.zip` plus checksums + summary entries listing the architecture. Mirror Linux summary content for clarity.
   - Ensure the script can accept `PACKAGE_RELEASE_ARCH_OVERRIDE` (if needed) so CI can build both architectures from a single host (xcodebuild’s `-destination 'platform=macOS,arch=x86_64'`). Evaluate whether cross-compiling within GitHub runners suffices or whether Rosetta is required.

2. **Homebrew Formula Automation**
   - Introduce a helper (e.g., `Scripts/build_homebrew_formula.py`) that takes version, tap repo path, URLs for each architecture, and checksums. It should output a deterministic Ruby formula (class `Docc2context`) with `sha256` per arch block and a `test do` invoking `docc2context --version`.
   - Add snapshot-style tests verifying the rendered formula for a fake version so future releases do not regress the structure. Tests can live under `Tests/Docc2contextCLITests` or a new target (e.g., `HomebrewFormulaBuilderTests`).
   - Document how to push the generated formula to a tap (likely `docc2context/homebrew-tap`), including git commands or GitHub Actions automation. If automation is deferred, capture the manual steps in the README/release checklist.

3. **Manual Install Script + README Update**
   - Author a macOS install helper (shell script) that downloads the correct zip based on detected architecture, verifies the `.sha256`, unzips, and moves `docc2context` into `/usr/local/bin` or `/opt/homebrew/bin`. The script should default to `/usr/local/bin` for Intel, `/opt/homebrew/bin` for Apple Silicon, with `--prefix` override.
   - Expand README installation section with:
     - Homebrew tap commands (`brew tap docc2context/tap && brew install docc2context`).
     - Manual download commands for both architectures with checksum verification and final location guidance.
     - One-line install script invocation (e.g., `curl -fsSL https://.../install-macos.sh | bash`).
   - Update `DocumentationGuidanceTests` snapshots to include the new sections and ensure linting passes.

4. **Codesign & Notarization Documentation/Automation**
   - Document prerequisites (Developer ID Application cert, Keychain unlock, App Store Connect API key JSON) and environment variables consumed by the release script (`MACOS_SIGN_IDENTITY`, `NOTARYTOOL_PROFILE`, etc.).
   - Decide whether to build a `Scripts/notarize_macos_binary.sh` helper that runs `notarytool submit`, polls for completion, and staples the ticket onto the zip before upload. Even if notarization remains manual, provide a reproducible checklist referencing Apple commands plus expected log outputs.
   - Capture how to surface notarization state in release notes (e.g., include a badge or summary entry) so users know whether the downloadable zip is stapled.

5. **Release Workflow & Validation Updates**
   - Extend `.github/workflows/release.yml` to:
     - Build both macOS architectures (arm64 runner + `macos-13` x86 runner or a universal binary build using `xcodebuild` `-destination`).
     - Upload Homebrew formula artifact (or open PR in tap repo) after packaging completes.
     - Run a smoke `brew install --build-from-source ./Formula/docc2context.rb && docc2context --version` job using the generated formula to ensure future releases do not break the tap.
   - Update release documentation to mention the new workflow steps and gating (e.g., the release checklist now includes verifying `brew test docc2context`).

6. **Testing & Tooling Strategy**
   - Add unit tests covering any new scripting logic (formula builder, install script options). Where shell scripts are hard to test, add integration tests under `Scripts/tests/` invoked via `swift test` or `bash` harness to keep coverage and determinism guardrails.
   - Ensure `Scripts/release_gates.sh` invokes the macOS install script in a dry-run mode (if feasible) so it remains deterministic and linted.

## Risks & Open Questions
- **Apple Signing Assets** — The repo may not have credentials for codesign/notarization in CI. Need to determine whether we rely on maintainers to run release packaging locally (with secrets) or configure GitHub Action secrets for the release job.
- **Homebrew Tap Hosting** — Confirm final tap location (`docc2context/homebrew-tap` vs. upstream `homebrew/core`). SELECT_NEXT assumes a private tap for faster iteration; START work should validate repo availability and automation permissions.
- **x86_64 Build Availability** — GitHub’s macOS runners are arm64-only today; cross-compiling x86_64 might require `macos-13` Intel runners (limited supply) or building a universal binary locally. Need to prototype best approach during START.

## Immediate Next Actions (before START)
1. Socialize this plan in the next STATE update so stakeholders agree D4-MAC is the top priority coming out of SELECT_NEXT.
2. Confirm maintainers have/are willing to provision the required Apple Developer ID credentials for codesign/notarization; without them, acceptance criteria may need staged delivery (document-only vs. automated signing).
3. Decide on the exact tap repository path and access strategy so implementation can wire scripts/tests without guessing remote URLs.

## START Execution (2025-11-19)
- **Packaging** – `Scripts/package_release.sh` now outputs macOS zips with architecture suffixes (arm64/x86_64) and summary files reflecting the arch. Release workflow gains `macos-latest` (arm64) and `macos-13` (x86_64) jobs plus a publish-stage Homebrew formula render driven by `Scripts/build_homebrew_formula.py`; upload names are arch-qualified.
- **Distribution tooling** – Added deterministic Homebrew formula builder and macOS install helper (`Scripts/install_macos.sh`) with arch detection, checksum verification, and `--dry-run` to prevent accidental downloads during CI or tests.
- **Docs** – README adds Homebrew tap commands, manual macOS install steps, the curl-able install helper, and explicit codesign/notarytool/stapler guidance for prebuilt zips.
- **Validation** – `swift test` (2025-11-19) passes with new coverage; packaging/installer/formula tests exercised locally. Linux packaging test still skips on macOS hosts until dpkg/rpmbuild are available.
- **Follow-ups** – Coordinate tap publishing workflow/permissions and Apple signing credentials for notarization in CI; archive this task once release stakeholders confirm the tap destination and signing secret handling.

## macOS Release Process Validation Manual (2025-11-21)

### Current Status: ✅ Mostly Validated (Matches Proposed Plan & PRD §4.6)
The implementation aligns closely with the **Proposed Plan of Attack** and **START Execution** notes in this document. Key files inspected: `.github/workflows/release.yml`, `Scripts/package_release.sh`, `Scripts/build_homebrew_formula.py`, `Scripts/install_macos.sh`, `README.md`. `swift test` passes fully (27 executed/9 skipped placeholders, including `HomebrewFormulaBuilderTests` and `MacInstallScriptTests`).

Detailed validation against acceptance criteria below.

#### 1. Artifact Naming & Release Script Enhancements (`Scripts/package_release.sh`) ✅
- Supports `--platform macos --arch arm64|x86_64`, emits `docc2context-v<version>-macos-<arch>.zip` + `.sha256` + `.md` summary (arch, gates, timestamps, artifacts).
- Builds `swift build -c release`, codesigns if `MACOS_SIGN_IDENTITY` set.
- Zip: `docc2context` (executable), `README.md`, `LICENSE`.

**Validation** (local arm64 host):
```
cd docc2context
Scripts/package_release.sh --version 0.1.0 --platform macos --arch arm64 --output dist
```
Produces:
```
dist/docc2context-v0.1.0-macos-arm64.zip
dist/docc2context-v0.1.0-macos-arm64.zip.sha256
dist/docc2context-v0.1.0-macos-arm64.md
```
*Note*: `--arch x86_64` on arm64 names correctly but builds arm64 (no cross-compile); CI uses separate runners.

#### 2. Homebrew Formula Automation (`Scripts/build_homebrew_formula.py`) ✅
- Deterministic `docc2context.rb`: `on_macos { on_arm/on_intel }` with URLs/SHA256, `test do` (`docc2context --version`), MIT license.

**Validation**:
```
ARM_SHA="$(cut -d' ' -f1 dist/docc2context-v0.1.0-macos-arm64.zip.sha256)"
python3 Scripts/build_homebrew_formula.py \
  --version 0.1.0 \
  --arm64-url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-arm64.zip" \
  --arm64-sha256 "$ARM_SHA" \
  --x86_64-url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-x86_64.zip" \
  --x86_64-sha256 "abc123placeholder" \
  --output dist/homebrew/docc2context.rb
```
Output (matches `HomebrewFormulaBuilderTests` snapshot):
```ruby
#/dev/null/docc2context.rb#L1-25
class Docc2context < Formula
  desc "Convert DocC bundles to deterministic Markdown plus link graphs"
  homepage "https://github.com/SoundBlaster/docc2context"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-arm64.zip"
      sha256 "<actual-sha>"
    end

    on_intel do
      url "https://github.com/SoundBlaster/docc2context/releases/download/v0.1.0/docc2context-v0.1.0-macos-x86_64.zip"
      sha256 "<actual-sha>"
    end
  end

  def install
    bin.install "docc2context"
    prefix.install "README.md", "LICENSE"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docc2context --version")
  end
end
```
Uploaded in `release.yml` publish job (fails sans macOS zips).

#### 3. Manual Install Script + README (`Scripts/install_macos.sh`) ✅
- Detects arch, downloads/verifies, installs to `/opt/homebrew/bin` (arm64)/`/usr/local/bin` (x86_64), `--prefix`/`--dry-run`.

**Validation**:
```
Scripts/install_macos.sh --version v0.1.0 --dry-run
```
Logs: artifact URL, checksum, `/opt/homebrew/bin/docc2context`.

`README.md` (L178-254): Homebrew tap, manual curl/unzip, one-liner `curl -fsSL https://.../install_macos.sh | bash -s -- --version v1.2.3`. Matches `DocumentationGuidanceTests`.

#### 4. Codesign & Notarization 🔄 (Docs ✅, CI Manual)
- Script honors `MACOS_SIGN_IDENTITY`.
- `README.md`: `codesign --force --options runtime --timestamp --sign ...`, `notarytool submit --wait`, `stapler staple`.
- Local: `export MACOS_SIGN_IDENTITY="-" && package_release.sh ...` (skips).

#### 5. Release Workflow (`.github/workflows/release.yml`) ✅
- Triggers: tags `v*`.
- Matrix: linux-x86_64/aarch64 + macos-arm64 (`macos-latest`)/x86_64 (`macos-13`).
- Packages/uploads per-matrix; publish generates/uploads formula + assets.
- *Gap*: No `brew install --build-from-source && docc2context --version` smoke test.

#### 6. Tests & Gates ✅
- `swift test`: Passes (e.g., 2025-11-21 run: All suites green).
- New: `HomebrewFormulaBuilderTests`, `MacInstallScriptTests`.
- `release_gates.sh`: Pre-package (coverage/lint/determinism).

### Gaps & Recommendations 🔄
1. **Tap Publishing** (`docc2context/tap`?): Formula ready; manual `brew tap-new ...; git commit Formula/docc2context.rb`. Automate: `publish` job w/ `gh` CLI + PAT secret. Test: `brew install docc2context && docc2context --version`.
2. **CI Signing/Notarization**: GH secrets (`MACOS_SIGN_IDENTITY`, App Store Connect key). Add post-package `notarytool`.
3. **x86_64 Local** (arm64 host): `arch -x86_64 swift build ...` or `PACKAGE_RELEASE_BINARY_OVERRIDE`.
4. **E2E Sim**: `git tag v0.1.0`; trigger GH workflow (skip gates if needed).

**Next**: Resolve follow-ups → Archive to `DOCS/TASK_ARCHIVE/` per runbook (D4-MAC complete).

## Binary Runtime Validation (2025-11-21)
- Binary executable: ✅ Runs `--version`/`--help`, rejects invalid bundles (Info.plist check).
- Error: Expected for placeholder parser (B3/B4). Full E2E after Phase B fixtures.
