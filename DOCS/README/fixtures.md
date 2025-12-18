# Fixtures

The repository ships curated DocC bundles in `Fixtures/` (for example `TutorialCatalog.doccarchive`, `ArticleReference.doccarchive`, and `Docc2contextCore.doccarchive`).

Each fixture entry is tracked inside `Fixtures/manifest.json` with:
- SHA-256 checksum
- byte size

Validate fixture integrity locally:

```bash
python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json
```

Notes:
- Tests consume committed fixture artifacts only (no DocC generation during `swift test`).
- Regenerating `Fixtures/Docc2contextCore.doccarchive` should follow the pinned provenance described in `DOCS/TASK_ARCHIVE/42_S0_DocCGenerationNotes/DocCGenerationNotes.md`.

