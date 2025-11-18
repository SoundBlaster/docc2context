# D4-LNX Linux Release Packaging Matrix

## Source Material & Links
- PRD §4.6 Release Packaging & Distribution Requirements (`DOCS/PRD/docc2context_prd.md`)
- Workplan §Phase D sequencing (`DOCS/workplan.md`)
- TODO entry promoted to In Progress (`DOCS/todo.md`)
- Archived D4 release automation baseline (`DOCS/TASK_ARCHIVE/24_D4_PackageDistributionRelease/`)

## Scope & Acceptance Criteria
- Produce architecture-specific Linux tarballs named `docc2context-<version>-linux-<arch>.tar.gz` using the existing release gate so uploads remain conditioned on determinism + coverage checks.
- Generate `.deb` and `.rpm` installers via `fpm` or `nfpm` that install the binary under `/usr/local/bin` with version metadata, maintainer info, and dependency declarations aligned with PRD §4.6.
- Emit SHA256 (and optional GPG signature) artifacts alongside every package.
- Document manual install commands (`curl | tar` + `sudo mv`), and provide `dpkg -i`/`dnf install` snippets referencing the GitHub release URLs inside README.
- Capture open questions for hosting apt/dnf repos and musl builds as stretch goals so they can be promoted later without blocking tarball/package delivery.

## Dependencies & Current State
- D4 release automation already builds tagged binaries and uploads tarballs/hashes (`Scripts/package_release.sh`, CI workflow). Need to extend to multiple Linux targets without regressing macOS outputs.
- Packaging scripts currently assume tarball-only artifacts; `.deb`/`.rpm` packaging tools (`fpm`/`nfpm`) are not yet wired into CI. Validate availability on GitHub Actions runners or vendor via Docker container.
- README `Installation` section covers baseline release workflow but lacks Linux package manager instructions.

## Proposed Plan
1. **Audit Release Script & CI Workflow**
   - Enumerate existing steps in `Scripts/package_release.sh` and GitHub release workflow to confirm where architecture loops should be inserted.
   - Decide whether to cross-compile or leverage separate Linux runners per architecture (likely `x86_64` + `arm64` via Swift 5.9 toolchains). Record assumptions + blockers.
2. **Prototype `.deb`/`.rpm` Generation Locally**
   - Add a dry-run helper (e.g., `Scripts/build_linux_packages.sh --dry-run`) that wraps `fpm`/`nfpm`, taking the release binary path + metadata (version, maintainer, license) and emitting packages into a staging directory.
   - Capture expected output tree plus validation commands (`dpkg-deb --info`, `rpm -qpi`).
3. **Wire Packaging Into Release Pipeline**
   - Update `Scripts/package_release.sh` to invoke the helper for each architecture, naming outputs deterministically and storing them beside tarballs + SHA256 files.
   - Ensure CI caches or installs `fpm`/`nfpm`; document fallback instructions if runners lack dependencies.
4. **README & Verification Updates**
   - Extend README installation instructions with `curl | tar`, `dpkg -i`, and `dnf install` snippets referencing release URLs and GPG signature verification commands.
   - Add smoke tests (likely in `PackageReleaseScriptTests`) that assert the packaging helper receives correct arguments and surfaces errors when `fpm`/`nfpm` fail.
5. **Stretch Goal Capture**
   - Document follow-ups for hosting apt/dnf repositories and producing musl-based static builds; keep them in TODO Backlog if not immediately implementable.

## Validation Strategy
- Unit/integration tests in `PackageReleaseScriptTests` covering new helper + script branches.
- CI proof by running `Scripts/package_release.sh --dry-run` (or equivalent) on Linux runner to confirm `.deb`/`.rpm` outputs appear with expected naming + hashes.
- Manual verification instructions for maintainers (`dpkg -c docc2context_*.deb`, `rpm -qlp docc2context-*.rpm`, `sha256sum --check`).

## Open Questions / Risks
- Availability of `fpm`/`nfpm` on GitHub-hosted runners; may require bundling via Docker or downloading prebuilt binaries.
- Whether Swift cross-compilation is needed for `arm64` Linux binaries or if release pipeline already produces them.
- Key management for GPG signatures (if required) and how to store secrets without exposing private keys in CI.

## Execution Notes – Cycle 6
- Implemented `Scripts/build_linux_packages.sh` to generate `tar.gz`, `.deb`, and `.rpm` artifacts per architecture with deterministic naming, metadata, and SHA-256 manifests. The helper wires directly into `package_release.sh` so Linux builds automatically expand into three install formats.
- Extended `Scripts/package_release.sh` with `--arch`, summary improvements, and Linux-specific packaging. macOS packaging retains zip behavior but now records the architecture in the summary for traceability.
- Updated `PackageReleaseScriptTests` to cover the new artifact layout end-to-end (dry-run of Linux packaging) and documented manual install snippets plus packaging flow changes in `README.md`.
- Release workflow now runs Linux `x86_64` and `aarch64` jobs plus macOS arm64, installing `rpm`/`dpkg-dev` dependencies before invoking the packaging script. Each job uploads tarballs, packages, checksums, and markdown summaries to the GitHub Release.

## Validation
- `swift test` exercises `PackageReleaseScriptTests` and the broader test suite to ensure the helper scripts are wired correctly.

## Follow-ups
- Investigate publishing apt/dnf repositories plus musl/static builds (tracked in TODO backlog) once the package formats prove stable in CI.
