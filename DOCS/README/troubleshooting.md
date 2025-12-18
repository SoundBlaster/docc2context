# Troubleshooting & FAQ

## Markdown lint failures

Run:

```bash
python3 Scripts/lint_markdown.py
```

## Coverage gate failures

Run:

```bash
swift test --enable-code-coverage
python3 Scripts/enforce_coverage.py --threshold 90
```

## Fixture manifest mismatches

If `Fixtures/manifest.json` checksum/size validation fails:

```bash
python3 Scripts/validate_fixtures_manifest.py Fixtures/manifest.json
```

