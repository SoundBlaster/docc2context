# Fixtures

This directory will host the deterministic DocC bundles exercised by the test harness.
It is created as part of task **A3 – Establish DocC Sample Fixtures** (see `DOCS/INPROGRESS/A3_DocCFixtures.md`).

## Layout Plan
- `<BundleName>.doccarchive/` – canonical DocC bundles checked into the repo.
- `manifest.json` – machine-readable catalog enumerating every bundle's checksum, size, and coverage notes.
- `README.md` – provenance and usage guidance (this file).

## Provenance & Licensing Checklist
1. Prefer first-party Swift packages that ship DocC content with permissive licenses (e.g., SamplePackage, SwiftUI tutorials snapshot).
2. Record download URLs, commit hashes, and license identifiers in the manifest.
3. Store only the assets required for tests (tutorial content, articles, symbol graphs) to keep repository size manageable.

## Determinism Expectations
- Every bundle entry in `manifest.json` must include a SHA-256 checksum and byte size.
- Contributors regenerating fixtures should run `shasum -a 256 <bundle>.doccarchive > <bundle>.sha256` and update the manifest.
- XCTest utilities from task A2 will load bundles relative to this folder; do not rearrange without updating the helper APIs.

## Pending Work
- Populate the manifest with at least two bundles (tutorial-focused + API/article-focused).
- Add provenance paragraphs for each bundle, noting redistribution terms.
- Document example XCTest code once fixtures land so tests can reference them directly.
