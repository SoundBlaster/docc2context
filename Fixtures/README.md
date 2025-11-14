# Fixtures

This directory will host the deterministic DocC bundles exercised by the test harness.
It is created as part of task **A3 – Establish DocC Sample Fixtures** (see `DOCS/INPROGRESS/A3_DocCFixtures.md`).

## Layout Plan
- `<BundleName>.doccarchive/` – canonical DocC bundles checked into the repo.
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

## Pending Work
- Populate the manifest with at least two bundles (tutorial-focused + API/article-focused).
- Add provenance paragraphs for each bundle, noting redistribution terms.
- Document example XCTest code once fixtures land so tests can reference them directly.
- Update `manifest.json` whenever bundles change so the release gate validation succeeds.
