# Fixture dogfooding

This package can generate a `.doccarchive` from its own sources using `swift package generate-documentation`.

The generated archive is committed under `Fixtures/` and consumed by XCTest so the converter is continuously tested against “real” DocC output (rather than only synthetic fixtures).

## Regenerating the fixture

Run the generation commands documented under `DOCS/TASK_ARCHIVE/42_S0_DocCGenerationNotes/DocCGenerationNotes.md`, then update `Fixtures/manifest.json` to reflect the new checksum + size and ensure `python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json` passes.

