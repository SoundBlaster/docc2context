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

## Self-Docs Artifacts

Every push to `main` automatically generates and uploads a self-docs artifact. This allows quick visual inspection of the converter output without running locally.

**To view the latest self-docs:**
1. Go to the [Actions tab](https://github.com/SoundBlaster/docc2context/actions/workflows/self-docs.yml)
2. Click the most recent "Generate Self-Docs Artifact" workflow run
3. Download the `docc2context-self-docs` artifact (Markdown files)
4. Optionally download `docc2context-link-graph` (link graph JSON)

The artifacts are generated from `Fixtures/Docc2contextCore.doccarchive`, so they reflect how the converter renders the self-documentation for the docc2context project itself. This provides a good baseline for comparing visual output quality and structure.

## More docs

- Contributing: `DOCS/README/contributing.md`
- CLI: `DOCS/README/cli.md`
- Fixtures: `DOCS/README/fixtures.md`
- Internals: `DOCS/README/internals.md`
- Releases: `DOCS/README/releases.md`
- Troubleshooting: `DOCS/README/troubleshooting.md`
