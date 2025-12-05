# docc2context

`docc2context` is a Swift command-line utility that converts DocC bundles and archives into deterministic Markdown chunks plus link graphs for LLM ingestion. The package currently contains a CLI target (`docc2context`), a reusable core library, and unit tests wired through Swift Package Manager.

## Development quick start

### 1. Install Swift

Swift 6.1.2 is the baseline toolchain for this repo. On macOS, install or select Xcode 16.4 (the version our CI pins) so the bundled Swift 6.1.2 SDK matches the GitHub runners. On Linux, download the Swift 6.1.2 release for Ubuntu 22.04 (or your distro) from [Swift.org](https://swift.org/download/).

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
# should contain "6.1.2"
```

### 3. Build & test locally

Use SwiftPM for everyday workflows:

```bash
swift build
swift test
```

The tests exercise the CLI target and keep the Linux/macOS builds honest.

### 4. Enforce coverage thresholds

Phase D requires both the CLI and the core library to maintain at least 90% line coverage. Generate coverage data and enforce the threshold locally before opening a PR:

```bash
swift test --enable-code-coverage
python3 Scripts/enforce_coverage.py --threshold 90
```

The helper script wraps `llvm-cov export -summary-only` and aggregates per-target coverage for the `Sources/docc2context` and `Sources/Docc2contextCore` trees. It fails fast when either target dips below the configured threshold so engineers can tighten tests before CI does.

### 5. Lint documentation

Documentation changes ship through the same guardrails as code. Run the Markdown lint helper before opening a PR so structural regressions (missing sections, trailing spaces, tabs) are caught locally:

```bash
python3 Scripts/lint_markdown.py README.md
```

Pass additional Markdown paths as arguments (for example, `DOCS/PRD/phase_d.md`) whenever you update deeper documentation trees.

## CLI usage

`docc2context` now executes the DocC → Markdown pipeline end-to-end. Running the command populates `<output>/markdown/` with deterministic files grouped into `tutorials/` (tutorial volumes + chapters) and `articles/` (reference content). Each invocation prints a concise summary showing how many tutorial volumes, chapters, reference articles, and symbols were rendered so scripts can validate expectations.

```
docc2context <input-path> --output <directory> [--format markdown] [--force] [--technology <name>]
```

- `<input-path>` – Required positional argument that points to a DocC bundle or `.doccarchive` to convert.
- `--output <directory>` – Required option describing where Markdown/link graph artifacts should be written. The directory is created if it does not already exist.
- `--format <value>` – Optional output format selector. For now only `markdown` is accepted; other values exit with code 64 and  include the supported list in the error text.
- `--force` – Optional boolean flag that allows the CLI to delete an existing output directory before writing fresh Markdown files.
- `--technology <name>` – Optional filter for symbol references by module/technology name. Can be specified multiple times to include symbols from multiple modules. When specified, only symbols matching the filter are included in the output; tutorials and articles remain unaffected.

Parsing errors exit with `EX_USAGE`/64 and human-readable guidance so scripts can detect misconfigurations early. `--help` prints the same usage and documents each supported flag. Successful conversions exit 0 after creating Markdown files on disk.

## Fixtures & sample DocC bundles

The repository ships two curated DocC bundles in `Fixtures/` (`TutorialCatalog.doccarchive` and `ArticleReference.doccarchive`). Each fixture entry is tracked inside `Fixtures/manifest.json` with its SHA-256 checksum and byte size so determinism tests can verify provenance. Offline repository metadata fixtures for apt/dnf live under `Fixtures/RepositoryMetadata` with their own manifest (`manifest.json`) validated by the Swift harness.

- **Inspecting fixtures** – Run `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json` to confirm hashes before recording new data. `swift test` depends on these bundles, so a mismatch indicates accidental edits.
- **Adding fixtures** – Compress the `.doccarchive`, calculate its SHA-256 hash (`shasum -a 256`), and append the metadata to the manifest. Update `Fixtures/README.md` with provenance notes so future contributors know the origin of each bundle.
- **Using fixtures in tests** – Leverage the harness utilities under `Tests/Shared/` to load fixture paths without duplicating boilerplate. `HarnessTemporaryDirectory` exposes scratch space for deterministic copy tests.

## Repository validation harness

`repository-validation` is a Swift CLI that validates repository metadata for both apt and dnf. It defaults to the offline fixtures shipped in `Fixtures/RepositoryMetadata`, verifying the manifest hashes, apt `Release`/`InRelease`/`Packages` contents, and dnf `repomd.xml`/`primary.xml` package details.

- **Fixture-mode (default):**

  ```bash
  swift run repository-validation --fixtures-path Fixtures/RepositoryMetadata
  ```

- **Staged overrides:** Supply alternate metadata without touching live credentials by passing override flags (for example, after downloading staged metadata to `/tmp/repo-metadata`):

  ```bash
  REPOSITORY_VALIDATION_FLAGS="--apt-release /tmp/repo-metadata/Release --apt-inrelease /tmp/repo-metadata/InRelease \
    --apt-packages /tmp/repo-metadata/Packages --dnf-repomd /tmp/repo-metadata/repodata/repomd.xml \
    --dnf-primary /tmp/repo-metadata/repodata/primary.xml --expected-version v1.2.3" \
    bash Scripts/release_gates.sh
  ```

The harness remains offline-first, emitting descriptive failures for mismatched versions, architectures, checksums, and manifest entries. Live probes stay opt-in via explicit override flags so CI remains deterministic.

## Testing & automation overview

Most contributions touch multiple automation layers. Keep the following workflow handy:

1. `swift build` – Confirm the package compiles before running tests.
2. `swift test` – Executes the entire suite, including CLI integration, determinism, and documentation guards such as `DocumentationGuidanceTests` and `InternalModelDocumentationTests`.
3. `swift test --enable-code-coverage` – Produces `.profdata` for coverage enforcement. Follow up with `python3 Scripts/enforce_coverage.py --threshold 90` to ensure both the CLI and core targets remain above the D2 floor.
4. `python3 Scripts/lint_markdown.py README.md DOCS/PRD/phase_d.md` – Validates Markdown formatting and asserts that required README sections exist. The script exits non-zero when a rule fails, matching the CI `docs` job.
5. `bash Scripts/release_gates.sh` – Runs tests with coverage, determinism smoke + full conversions, fixture validation, repository metadata checks, and coverage enforcement before you tag a release or push a significant change.

## Metadata parsing pipeline

`DoccMetadataParser` in the core library currently covers every metadata artifact that ships with DocC bundles so downstream Markdown rendering has strongly typed inputs without needing additional CLI flags. The parser expects the B3 input detection stage (and eventually the B4 archive extractor) to hand it a normalized bundle directory; within that directory it loads:

- `Info.plist` for bundle identifiers, localized display names, technology roots, and optional DocC/project version strings with typed errors for missing keys or invalid field types.
- `data/metadata/metadata.json` for render metadata describing generator details and format versions.
- `data/documentation/<TechnologyRoot>.json` for technology overview nodes, including abstracts and topic identifiers used to seed Markdown navigation.
- `data/symbol-graphs/*.json` for symbol references that are sorted deterministically by identifier/module names so later phases produce stable Markdown regardless of filesystem ordering.

These entry points power the `MetadataParsingTests` suite, which reads both tutorial and article fixtures to validate the behavior today while B6+ tasks wire the data into Markdown generation.

## Internal model overview

<!-- INTERNAL_MODEL_DOC_START -->
`DoccInternalModelBuilder` wires the parsed metadata into a `DoccBundleModel` so subsequent Markdown + link graph generation can treat the internal model as the single source of truth. The model currently exposes:

- `DoccBundleModel` – top-level struct combining bundle metadata, `DoccDocumentationCatalog`, tutorial volumes, and `DoccSymbolReference` arrays.
- `DoccDocumentationCatalog` – captures the technology catalog identifier, title, and topic sections that seed tutorial ordering.
- `DoccTutorialVolume` – represents each technology catalog emitted by DocC; tutorial volumes preserve the order established by DocC so determinism is unaffected by filesystem traversal.
- `DoccTutorialChapter` – each chapter maps to a `DoccDocumentationCatalog.TopicSection`, and chapters maintain the DocC topic order described in the source JSON.
- `DoccSymbolReference` – symbol references stay sorted by identifier/module names to guarantee deterministic lookups once link graphs are generated.

Ordering guarantees:

1. `DoccTutorialVolume` instances are emitted in the order DocC writes technology catalogs (today fixtures contain a single catalog, but the builder will maintain order once multiple catalogs appear).
2. The chapters maintain the DocC topic order exposed in the catalog’s `topics` array, ensuring sequential tutorial walkthroughs remain intact.
3. Each `DoccTutorialChapter` retains the `pageIdentifiers` ordering provided by DocC so Markdown snapshots mirror DocC navigation.

This README section is validated by `InternalModelDocumentationTests` to keep the documentation synchronized with the internal model contract as serialization coverage expands.

Deterministic JSON encoding of `DoccBundleModel` is guarded by `DoccInternalModelSerializationTests` and the recorded snapshot at `Tests/__Snapshots__/DoccInternalModelSerializationTests/tutorial-catalog.json`, so Phase C Markdown generators can rely on a stable serialized representation.
<!-- INTERNAL_MODEL_DOC_END -->

## Continuous Integration

GitHub Actions runs `swift build` and `swift test` on Ubuntu 22.04 and macOS. The Linux job relies on [`SwiftyLab/setup-swift`](https://github.com/SwiftyLab/setup-swift) to install Swift 6.1.2 and mirrors the package dependencies called out above so local and CI environments stay aligned. The macOS job selects Xcode 16.4 and uses its bundled Swift 6.1.2 toolchain to avoid mismatched SDK headers.

## Release gates and Determinism Verification

Run `Scripts/release_gates.sh` before tagging a release (or opening a PR) to exercise the same checks our CI gate will enforce:

```bash
Scripts/release_gates.sh
```

The script performs the following checks:

1. **Tests w/ Coverage** – Executes `swift test --enable-code-coverage` so `.build/debug/codecov/default.profdata` is always available for downstream gates.
2. **Coverage Enforcement** – Runs `Scripts/enforce_coverage.py --threshold 90` to ensure both the CLI and library targets maintain ≥90% line coverage.
3. **Determinism Smoke Test** – Runs a deterministic smoke test twice (defaults to `swift run docc2context --help`) and compares the SHA-256 hashes of the outputs. This verifies that command output is deterministic across runs.
4. **Full Output Determinism** – Converts the TutorialCatalog fixture twice to separate output directories and compares all generated Markdown files byte-for-byte, ensuring that the conversion pipeline produces identical outputs on repeated runs.
5. **Fixture Validation** – Validates `Fixtures/manifest.json` via `Scripts/validate_fixtures_manifest.py`, confirming that every listed bundle exists, matches the recorded checksum, and reports the expected byte size.
6. **Repository Metadata Validation** – Executes `swift run repository-validation --fixtures-path Fixtures/RepositoryMetadata` (plus any `REPOSITORY_VALIDATION_FLAGS` overrides) to confirm apt/dnf metadata and expected package versions/checksums match the offline fixtures.

All steps must succeed for the script to exit 0, making it suitable for CI wiring or pre-push hooks.

## Release packaging & automation

Once the release gates pass, package platform-specific binaries with `Scripts/package_release.sh`. The helper wraps `release_gates.sh`, builds the CLI in release mode, stages the binary alongside `README.md`/`LICENSE`, and now emits architecture-specific bundles:

- **Linux** – `docc2context-<version>-linux-<arch>.tar.gz` tarballs plus `.deb` (Debian/Ubuntu) and `.rpm` (Fedora/RHEL) installers. Each artifact ships with a `.sha256` file and is summarized inside `docc2context-v<version>-linux-<arch>.md`.
- **macOS** – `docc2context-v<version>-macos-<arch>.zip` archives (arm64 and x86_64) include codesigning when `MACOS_SIGN_IDENTITY` is provided. Zips are paired with `.sha256` manifests and summary markdown files that capture the architecture.

```bash
# Produce Linux artifacts (tar.gz + .deb + .rpm) for docc2context v1.2.3 on the current host architecture
Scripts/package_release.sh --version v1.2.3 --platform linux --output dist/linux

# Generate musl builds (universal Linux compatibility)
PACKAGE_RELEASE_SWIFT_BUILD_FLAGS="--swift-sdk x86_64-swift-linux-musl" \
  Scripts/package_release.sh --version v1.2.3 --platform linux --arch x86_64 --variant musl --output dist/linux

# Generate macOS builds (codesigned when MACOS_SIGN_IDENTITY is set)
Scripts/package_release.sh --version v1.2.3 --platform macos --arch arm64 --output dist/macos
Scripts/package_release.sh --version v1.2.3 --platform macos --arch x86_64 --output dist/macos

# Call the Linux packaging helper directly (dry run) when iterating on metadata
Scripts/build_linux_packages.sh --version 1.2.3 --arch x86_64 --stage-dir /tmp/stage --binary /tmp/stage/docc2context --output dist/linux --dry-run
```

Key behaviors:

1. **Quality gates first** – By default the script shells out to `Scripts/release_gates.sh` and exits if any gate fails. Pass `PACKAGE_RELEASE_SKIP_GATES=1` only inside automated smoke tests; real releases must keep the default.
2. **Deterministic staging** – Artifacts land in `docc2context-v<version>/` folders before being zipped/tarred, ensuring README/license snapshots stay aligned with the binary bits pulled from `swift build -c release`.
3. **Checksums & summaries** – Every artifact is paired with `<artifact>.sha256` plus a Markdown summary enumerating the platform, architecture, version, gate status, and UTC timestamp so the release checklist can reference concrete hashes.
4. **Optional signing** – When building macOS releases, set `MACOS_SIGN_IDENTITY` (and the usual Keychain state) so the script calls `codesign --options runtime --timestamp` before zipping.
5. **Homebrew tap automation** – The release workflow automatically generates and publishes the Homebrew formula to [SoundBlaster/homebrew-tap](https://github.com/SoundBlaster/homebrew-tap). Use `Scripts/build_homebrew_formula.py` to render an architecture-aware formula locally, or let the CI handle it during releases.

The GitHub Actions workflow at `.github/workflows/release.yml` now runs a Linux matrix for `x86_64` and `aarch64` plus macOS jobs for `arm64` and `x86_64`. Each job installs the platform prerequisites (`dpkg-dev` for `dpkg-deb`, `rpmbuild`, `zip`, and Swift 6.1.2), runs the packaging script with the appropriate `--arch`, uploads the Linux tarballs/packages alongside macOS zips, and publishes every archive + checksum to the GitHub Release so downstream automation can fetch binaries deterministically. The publish stage renders a Homebrew formula from the macOS artifacts and automatically commits it to the tap repository, eliminating manual formula updates. The Linux ARM job targets the GitHub-hosted `ubuntu-22.04-arm64` runner tier; if your repository lacks access to that image, provision a self-hosted ARM64 runner (labels: `self-hosted`, `linux`, `arm64`) and adjust the workflow matrix accordingly.

**Note:** Automated tap publishing requires the `TAP_REPO_TOKEN` secret to be configured in GitHub Actions. See [.github/SECRETS.md](.github/SECRETS.md) for setup instructions.

### Linux installation snippets

Every GitHub Release publishes the SHA-256 hashes next to the Linux tarball, `.deb`, and `.rpm`. Verify the checksum before installing.

**Choosing between glibc and musl builds:**

- **glibc (default)** — Standard Linux builds that work on most modern distributions (Ubuntu, Debian, Fedora, RHEL, etc.). Requires glibc 2.27+ compatibility.
- **musl (universal)** — Fully statically linked binaries that run on any Linux distribution, including Alpine, older distros with legacy glibc, and environments with glibc version mismatches. Recommended for maximum portability.

Install via whichever mechanism matches your environment:

- **Tarball (glibc)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64.tar.gz
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64.tar.gz.sha256
  shasum -a 256 -c docc2context-1.2.3-linux-x86_64.tar.gz.sha256
  tar -xzf docc2context-1.2.3-linux-x86_64.tar.gz
  sudo mv docc2context-v1.2.3/docc2context /usr/local/bin/
  ```

- **Tarball (musl / universal)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64-musl.tar.gz
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64-musl.tar.gz.sha256
  shasum -a 256 -c docc2context-1.2.3-linux-x86_64-musl.tar.gz.sha256
  tar -xzf docc2context-1.2.3-linux-x86_64-musl.tar.gz
  sudo mv docc2context-v1.2.3/docc2context /usr/local/bin/
  ```

- **Debian/Ubuntu (glibc)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context_1.2.3_linux_amd64.deb
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context_1.2.3_linux_amd64.deb.sha256
  shasum -a 256 -c docc2context_1.2.3_linux_amd64.deb.sha256
  sudo dpkg -i docc2context_1.2.3_linux_amd64.deb
  ```

- **Debian/Ubuntu (musl / universal)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context_1.2.3_linux_amd64-musl.deb
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context_1.2.3_linux_amd64-musl.deb.sha256
  shasum -a 256 -c docc2context_1.2.3_linux_amd64-musl.deb.sha256
  sudo dpkg -i docc2context_1.2.3_linux_amd64-musl.deb
  ```

- **Fedora/RHEL (glibc)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64.rpm
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64.rpm.sha256
  shasum -a 256 -c docc2context-1.2.3-linux-x86_64.rpm.sha256
  sudo dnf install docc2context-1.2.3-linux-x86_64.rpm
  ```

- **Fedora/RHEL (musl / universal)**

  ```bash
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64-musl.rpm
  curl -LO https://github.com/SoundBlaster/docc2context/releases/download/v1.2.3/docc2context-1.2.3-linux-x86_64-musl.rpm.sha256
  shasum -a 256 -c docc2context-1.2.3-linux-x86_64-musl.rpm.sha256
  sudo dnf install docc2context-1.2.3-linux-x86_64-musl.rpm
  ```

  The `.deb` installs the binary under `/usr/local/bin/docc2context` with documentation in `/usr/share/doc/docc2context/`. The `.rpm` layout matches so automation scripts can rely on consistent paths across distros. Both glibc and musl variants are functionally identical and produce byte-identical outputs (determinism preserved). Future work on apt/dnf repository hosting is tracked in the TODO backlog.

#### Cloudsmith APT/DNF repository (pending maintainer setup)

The release workflow now includes an optional Cloudsmith upload step (backed by `Scripts/publish_to_cloudsmith.sh`) so `.deb` and `.rpm` packages can ship via a hosted apt/dnf repository. The step remains **disabled until the maintainer provisions a Cloudsmith account/repository and secrets**. Once enabled, Linux users will be able to add the Cloudsmith repository and install with `apt install docc2context` / `dnf install docc2context` instead of downloading artifacts manually.

For now, continue using the manual tarball/apt/rpm commands above. Maintainer TODO:

- Configure `CLOUDSMITH_*` secrets documented in `.github/SECRETS.md` (owner, repository, API key, distribution/release slugs, optional component)
- Provision a Cloudsmith repository (e.g., `ubuntu/jammy` + `any-distro/any-version` for RPM) and verify dry-run uploads locally via `./Scripts/publish_to_cloudsmith.sh --dry-run`
- Trigger a tagged release once secrets are in place to publish packages automatically

#### Arch Linux / AUR packaging

  Use the released tarballs and checksums to generate a PKGBUILD offline, then build/install with `makepkg`:

  ```bash
  VERSION=v1.2.3
  python3 Scripts/build_aur_pkgbuild.py \
    --version $VERSION \
    --x86_64-url https://github.com/SoundBlaster/docc2context/releases/download/$VERSION/docc2context-${VERSION#v}-linux-x86_64.tar.gz \
    --x86_64-sha256 <paste-x86_64-sha256-from-release> \
    --aarch64-url https://github.com/SoundBlaster/docc2context/releases/download/$VERSION/docc2context-${VERSION#v}-linux-aarch64.tar.gz \
    --aarch64-sha256 <paste-aarch64-sha256-from-release> \
    --output PKGBUILD

  makepkg --cleanbuild --syncdeps --install
  ```

  The helper normalizes the version (stripping any leading `v`), writes architecture-specific `source_*` and `sha256sums_*` arrays, and installs the staged `docc2context`, `README.md`, and `LICENSE` from the tarball into `/usr/local/bin` and `/usr/share/doc/docc2context`. It works with both glibc and musl tarballs as long as the matching checksum is provided.

### macOS installation snippets

**Homebrew tap (recommended)**

```bash
brew tap docc2context/tap
brew install docc2context
brew test docc2context
```

**Manual install from GitHub Releases**

```bash
VERSION=v1.2.3
ARCH=$(uname -m) # arm64 on Apple Silicon, x86_64 on Intel
curl -LO https://github.com/SoundBlaster/docc2context/releases/download/$VERSION/docc2context-v${VERSION#v}-macos-${ARCH}.zip
curl -LO https://github.com/SoundBlaster/docc2context/releases/download/$VERSION/docc2context-v${VERSION#v}-macos-${ARCH}.zip.sha256
shasum -a 256 -c docc2context-v${VERSION#v}-macos-${ARCH}.zip.sha256
unzip docc2context-v${VERSION#v}-macos-${ARCH}.zip
DEST=/usr/local/bin/docc2context
if [[ "$ARCH" == "arm64" ]]; then DEST=/opt/homebrew/bin/docc2context; fi
sudo install -m 0755 docc2context-v${VERSION#v}-macos-${ARCH}/docc2context "$DEST"
```

**One-line install helper**

```bash
curl -fsSL https://github.com/SoundBlaster/docc2context/raw/main/Scripts/install_macos.sh | bash -s -- --version v1.2.3
```

The script downloads the architecture-specific zip, verifies the `.sha256`, and installs to `/opt/homebrew/bin` on Apple Silicon or `/usr/local/bin` on Intel. Override the target directory with `--prefix <path>` and add `--dry-run` to print the planned commands without downloading.

**Codesign & notarization**

- Codesign local release builds with `codesign --force --options runtime --timestamp --sign "$MACOS_SIGN_IDENTITY" docc2context`.
- Submit zips for notarization and staple the ticket: `xcrun notarytool submit <zip> --keychain-profile <profile> --wait` then `xcrun stapler staple <zip>`.
- Release automation honors `MACOS_SIGN_IDENTITY` during packaging; notarization can be run manually or in CI once Apple API keys are configured.

## Troubleshooting & FAQ

**Coverage script fails below 90%** – Re-run `swift test --enable-code-coverage` and then `python3 Scripts/enforce_coverage.py --threshold 90` to gather the latest data. The JSON summary lists both the CLI and core targets; focus on the lower one. Add failure-path tests (for example, new cases in `MarkdownGenerationPipelineTests`) instead of disabling coverage.

**Release gates cannot find `llvm-cov`** – Ensure the Swift toolchain is accessible. On macOS, the script automatically uses `xcrun --find llvm-cov` to locate the tool in the Xcode toolchain. On Linux, it searches alongside `swift` in your `PATH`. If automatic detection fails, set the `LLVM_COV` environment variable to the absolute path before running `Scripts/release_gates.sh`.

**Doc lint job failed in CI** – Reproduce locally with `python3 Scripts/lint_markdown.py README.md` (and any additional Markdown paths you touched). The script prints file/line diagnostics for trailing whitespace, tab characters, CR line endings, and missing README sections. Fix the reported lines and rerun the command until it exits 0.

**Determinism job reports mismatched directories** – Inspect the per-file diff in `determinism.log` (produced by `Scripts/release_gates.sh`). Determinism regressions frequently stem from unordered file system enumerations; apply `sorted()` or deterministic comparators before writing Markdown.

### Determinism Testing

The project includes comprehensive determinism tests in `DeterminismTests.swift` that validate:

- **Consecutive Run Output Matching** – Multiple conversions of the same DocC bundle produce byte-identical Markdown files
- **Link Graph Determinism** – Link graph JSON files are generated identically across runs
- **TOC and Index Determinism** – Table of contents and index files are generated consistently
- **File-Level Hashing** – Individual file content is stable and reproducible

The `DeterminismValidator` class in `Docc2contextCore` provides utilities for:

- Computing file hashes using a deterministic hash algorithm
- Computing directory hashes by combining all file hashes in sorted order
- Comparing two directories and reporting any differences

These utilities are used by both the release gates script and the unit tests to ensure conversion determinism is maintained as features evolve.

## Project documentation

Roadmap planning, task coordination, and historical notes live under the `DOCS/` directory (e.g., `DOCS/workplan.md`, `DOCS/todo.md`, and `DOCS/INPROGRESS/`). Consult those files for the latest status instead of treating this README as a task tracker.
