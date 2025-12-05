# Fixtures

This directory hosts deterministic fixtures consumed by the test harness. It
originated from task **A3 – Establish DocC Sample Fixtures** (see the archived
notes under `DOCS/TASK_ARCHIVE/06_A3_DocCFixtures/`) and now includes offline
repository metadata to support the H4 validation harness.

## Layout Plan
- `<BundleName>.doccarchive/` – canonical DocC bundles checked into the repo.
- `RepositoryMetadata/` – offline apt/dnf metadata fixtures with a dedicated
  manifest for hash/size validation.
- `manifest.json` – machine-readable catalog enumerating every bundle's checksum, size, relative path, and coverage notes.
- `README.md` – provenance and usage guidance (this file).

## Provenance & Licensing Checklist
1. Prefer first-party Swift packages that ship DocC content with permissive licenses (e.g., SamplePackage, SwiftUI tutorials snapshot).
2. Record download URLs, commit hashes, and license identifiers in the manifest.
3. Store only the assets required for tests (tutorial content, articles, symbol graphs) to keep repository size manageable.

## Determinism Expectations
- Every bundle entry in `manifest.json` must include:
  - `relative_path` – location of the `.doccarchive` relative to this directory.
  - `checksum.algorithm` + `checksum.value` – SHA-256 hash of the bundle contents.
  - `size_bytes` – sum of the bundle's file sizes.
- Contributors regenerating fixtures should run `shasum -a 256 <bundle>.doccarchive > <bundle>.sha256` and update the manifest along with the byte size.
- XCTest utilities from task A2 will load bundles relative to this folder; do not rearrange without updating the helper APIs.
- The release gate script (`Scripts/release_gates.sh`) invokes `Scripts/validate_fixtures_manifest.py` to ensure the manifest matches the on-disk bundles.

## Bundles

### Tutorial Catalog (`TutorialCatalog.doccarchive`)
- **Focus:** Tutorials + knowledge checks that mimic DocC learning paths.
- **Synthetic source:** Authored specifically for docc2context fixtures; no upstream
  licensing requirements.
- **Highlights:**
  - `data/tutorials/getting-started.json` models a multi-step tutorial with
    assessments for CLI validation.
  - `data/documentation/tutorialcatalog.json` links the tutorial collection back to
    the technology catalog for integration tests.
- **Usage notes:** Ideal for smoke tests covering tutorial metadata parsing and
  future Markdown snapshot generation.

### Article Reference (`ArticleReference.doccarchive`)
- **Focus:** Article + API style content with symbol graph references.
- **Synthetic source:** Authored in-repo; redistribution approved under CC0.
- **Highlights:**
  - `data/documentation/articles/intro-article.json` describes article linking
    semantics.
  - `data/symbol-graphs/sample.symbols.json` supplies a lightweight symbol graph
    to keep the repository size small while enabling symbol parsing coverage.
- **Usage notes:** Designed for parser/unit tests that need realistic article and
  symbol payloads without depending on external downloads.

## Maintenance Notes
- Update `manifest.json` whenever bundles change so the release gate validation
  succeeds.
- Record provenance updates (date, author) inside the bundle-specific notes above
  when adding or editing content.
- Document example XCTest code once fixtures feed integration tests so future
  contributors understand how to load the manifest.

## Repository metadata fixtures

- **Location:** `Fixtures/RepositoryMetadata`
- **Contents:** Minimal apt (Release, InRelease, Packages) and dnf
  (`repodata/repomd.xml`, `repodata/primary.xml`) metadata paired with a
  manifest (`manifest.json`) that records SHA-256 hashes and byte sizes.
- **Purpose:** Enables offline validation harnesses to verify repository
  metadata deterministically without reaching live package hosts.
- **Validation:** `RepositoryMetadataFixturesValidator` (Swift) computes hashes
  and sizes for each entry and reports mismatches; see
  `RepositoryMetadataFixturesTests` for usage. The `repository-validation`
  executable extends this to validate apt/dnf metadata structures end-to-end
  (Release/InRelease/Packages + repomd.xml/primary.xml) using these fixtures by
  default.
