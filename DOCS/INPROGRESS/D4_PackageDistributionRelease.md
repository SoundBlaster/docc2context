# D4 – Package Distribution & Release Automation (Planning)

## Task Overview
- **PRD Reference:** [`DOCS/PRD/phase_d.md`](../PRD/phase_d.md) – D4 requires a reproducible release workflow that emits signed binaries for Linux and macOS only after all quality gates succeed.
- **Current Status:** D1–D3 are archived per the [workplan](../workplan.md); automation currently stops at `Scripts/release_gates.sh`, so there is no script that builds upload-ready artifacts or records the release checklist.
- **Goal:** Decide how to package deterministic CLI binaries, wire them to CI, and document the release checklist before implementing via `START`.

## Success Criteria
1. `swift build -c release` artifacts for Linux + macOS captured per version/tag, with naming like `docc2context-vX.Y.Z-${platform}.zip`.
2. Release script refuses to proceed unless `Scripts/release_gates.sh` (tests + determinism + coverage + docs lint) passes.
3. macOS artifacts are codesigned/notarized via CI secrets while Linux builds capture checksum manifests.
4. README + release documentation describe the workflow, environment variables, and manual verification steps.
5. Each tagged release appends a checklist entry under `DOCS/TASK_ARCHIVE/` (or CHANGELOG) referencing build logs and hashes.

## Dependencies & Inputs
- Existing automation (`Scripts/release_gates.sh`, coverage + determinism jobs) act as prerequisites.
- Git tags / semantic versioning source of truth (needs alignment with Package.swift `docc2context` version string).
- GitHub Actions credentials for uploading release assets + macOS signing identity (store via repository secrets when implementing).
- Fixture archives must remain unchanged so release artifacts stay deterministic; rely on manifest validation before packaging.

## Proposed Deliverables
1. **Packaging Script (`Scripts/package_release.sh`):**
   - Accepts `--version`, `--platform`, `--dry-run`, and output directory flags.
   - Runs `Scripts/release_gates.sh` up front; aborts on failure.
   - Invokes `swift build -c release` (Linux) or `xcodebuild -scheme docc2context -configuration Release` (macOS runner) and stages binaries plus README/license.
   - Produces `.zip` bundles with SHA-256 checksum files.
2. **CI Release Job:**
   - New GitHub Actions workflow triggered on version tags.
   - Matrix for `ubuntu-latest` and `macos-latest`; each job runs `package_release.sh` for its platform, uploads artifacts, and on success publishes GitHub release notes referencing checklist output.
3. **Documentation Updates:**
   - README “Releasing” section describing prerequisites, how to run the script locally, expected outputs, and verification commands.
   - `DOCS/TASK_ARCHIVE` template/checklist (e.g., `release_checklist_template.md`) capturing gates passed, artifact hashes, and upload links.
4. **Validation Artifacts:**
   - Shell-based smoke test (possibly `Scripts/tests/package_release_smoke.sh`) that runs the script in `--dry-run` mode to ensure gating + artifact staging behavior is testable on Linux CI.

## Execution Plan
1. **Finalize Versioning Strategy**
   - Decide on semver source (Git tag vs. `Package.swift` constant) and update README/PRD if needed.
   - Add helper (maybe `Scripts/lib/versioning.sh`) to parse the version for reuse in scripts/CI.
2. **Design Packaging Script API**
   - Outline CLI options, logging, and failure paths.
   - Ensure the script reuses deterministic temp directories and cleans up after packaging to avoid leaking intermediate builds.
3. **Integrate Quality Gates**
   - Embed `Scripts/release_gates.sh` invocation + guard rails (exit on failure, surface logs in summary file) to satisfy PRD requirement that releases only occur after gates pass.
4. **Plan Artifact Layout**
   - Define folder structure inside each `.zip` (binary, README excerpt, license, checksums, sample command list).
   - Document necessary signing/notarization commands for macOS (environment variables for identity/cert, `codesign --options runtime --timestamp`).
5. **CI Workflow Outline**
   - Draft GitHub Actions workflow steps (checkout → toolchain cache → `package_release.sh` → upload artifact → create release).
   - Include steps for secret management (signing identity, `GH_TOKEN`) and concurrency (only run on tags).
6. **Documentation & Checklist Prep**
   - Plan README section structure and determine where to store release logs/checklist entries (likely `DOCS/TASK_ARCHIVE/24_D4_PackageDistributionRelease/` once done).
   - Sketch checklist template capturing: tag/version, commit SHA, release gates timestamp, `swift build -c release` output snippet, artifact hashes, upload confirmation links.
7. **Testing Strategy**
   - Identify automation-friendly tests: add `Scripts/tests/package_release_smoke.sh` invoked from CI to validate `--dry-run` on Linux, plus unit-style shell tests verifying version parsing + gating logic.
   - Determine how to simulate signing steps in CI (mock commands under `--dry-run`?). Document fallback for local verification.

## Risks / Open Questions
- Need to confirm whether macOS signing/notarization can happen via GitHub Actions without manual intervention. If not, document manual signing fallback.
- Windows builds are out of scope per PRD; ensure docs explicitly limit support to Linux/macOS to avoid future confusion.
- Artifact size could be large because fixtures aren’t included, but we should document expected output sizes/checksums to detect regressions.

## Next Steps Before START
- Review this plan against stakeholders’ expectations (PRD + TODO) and confirm no other Phase D prerequisites remain.
- Once approved, run `COMMANDS/START.md` referencing this INPROGRESS note and begin implementing the packaging script + CI workflow.
