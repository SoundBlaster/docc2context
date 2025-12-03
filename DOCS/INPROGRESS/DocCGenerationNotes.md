# DocC generation + iterative development notes

This note answers whether we can generate DocC from the actual Swift code in this Swift Package Manager (SPM) project and reuse the output to grow features incrementally.

## Can we generate DocC from the SPM codebase?
Yes. The package already exposes a SwiftPM manifest (`Package.swift`) with library + executable targets, so `swift-docc` can render documentation directly from the source. Swift 5.9+ ships DocC with the toolchain on both macOS and Linux, letting us stay offline-friendly per the repo guidelines.

## How to produce DocC archives from the package
1. Build with symbol graph emission so DocC can resolve topics:
   ```bash
   swift build --target docc2context --product docc2context --enable-automatic-symbol-graphs
   ```
2. Generate documentation into a `.doccarchive` using the built products:
   ```bash
   swift package generate-documentation \
     --target docc2context \
     --output-path .build/doccarchives/docc2context.doccarchive \
     --transform-for-static-hosting \
     --hosting-base-path docc2context
   ```
   - Use `--disable-indexing` if the environment lacks Spotlight.
   - On Linux, supply `--experimental-documentation-workspace` if DocC requests it.
3. Inspect the resulting archive with `docc convert` (macOS) or re-run our converter to validate deterministic Markdown output.

## Using DocC output to iterate on features
- Feed the generated `.doccarchive` into the existing converter pipeline (CLI target `docc2context`) to produce Markdown/link graph snapshots. This keeps feature work grounded in real code semantics instead of synthetic fixtures.
- Record new snapshots under `Tests/__Snapshots__/` when expanding renderer coverage so tests enforce parity between DocC output and our Markdown.
- For recursive complexity increases (e.g., richer symbol pages, new callout types), iterate by:
  1. Expanding the Swift code with DocC comments that model the desired feature.
  2. Regenerating the DocC archive using the commands above.
  3. Updating or adding snapshot tests that assert the converter preserves the new content deterministically.
  4. Enhancing parsers/renderers to satisfy the snapshots while keeping determinism checks green.

## Guardrails
- Keep generation deterministic by pinning Swift toolchain version and avoiding host-specific paths in DocC commands.
- Store any new sample archives under `Fixtures/` with manifest entries so determinism and provenance checks remain intact.
- Prefer incremental PRs: add DocC content → regenerate archive → extend tests → implement feature → document outcomes in `DOCS/INPROGRESS/`.
