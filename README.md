# docc2context

`docc2context` converts DocC archives into deterministic Markdown + a link graph for LLM ingestion.

## Quick start

Clone the repo:

```bash
git clone git@github.com:SoundBlaster/docc2context.git
```

From the repo root:

```bash
swift run docc2context Fixtures/Docc2contextCore.doccarchive --output /tmp/docc2context-out --force --symbol-layout single
open /tmp/docc2context-out/markdown/documentation/docc2contextcore/benchmarkcomparator.md
```

Outputs:
- Markdown files: `/tmp/docc2context-out/markdown/`
- Link graph: `/tmp/docc2context-out/linkgraph/adjacency.json`

## More docs

- Contributing: `DOCS/README/contributing.md`
- CLI: `DOCS/README/cli.md`
- Fixtures: `DOCS/README/fixtures.md`
- Internals: `DOCS/README/internals.md`
- Releases: `DOCS/README/releases.md`
- Troubleshooting: `DOCS/README/troubleshooting.md`
