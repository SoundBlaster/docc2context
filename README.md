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

## CLI Usage & Options

```bash
docc2context <input-path> --output <directory> [options]
```

### Required Arguments

| Argument | Description |
|----------|-------------|
| `<input-path>` | Path to a DocC bundle directory or `.doccarchive` directory |

### Required Options

| Option | Description |
|--------|-------------|
| `--output <dir>` | Target directory for Markdown + link graph outputs |

### Optional Flags & Options

| Flag | Description | Default |
|------|-------------|---------|
| `-h, --help` | Show help message and exit | — |
| `--force` | Overwrite output directory if it already exists | false |
| `--format <value>` | Output format; only `markdown` is supported | `markdown` |
| `--technology <name>` | Filter symbols by technology/module name (repeatable) | none |
| `--symbol-layout <layout>` | Symbol page output layout: `tree` or `single` | `tree` |
| `--tutorial-layout <layout>` | Tutorial output layout: `chapter` or `single` | `chapter` |

### Examples

**Basic conversion with default settings:**
```bash
docc2context MyDocs.doccarchive --output ./docs-md
```

**Single-page symbol layout (one .md file per symbol):**
```bash
docc2context MyDocs.doccarchive --output ./docs-md --symbol-layout single
```

**Single-page tutorial layout (flat tutorial structure):**
```bash
docc2context MyDocs.doccarchive --output ./docs-md --tutorial-layout single
```

**Filter symbols by technology (module name):**
```bash
docc2context MyDocs.doccarchive --output ./docs-md --technology MyFramework
```

**Multiple technology filters:**
```bash
docc2context MyDocs.doccarchive --output ./docs-md --technology MyFramework --technology OtherModule
```

**Combined options (overwrite existing output, single layouts):**
```bash
docc2context MyDocs.doccarchive --output ./docs-md --force --symbol-layout single --tutorial-layout single
```

### Output Structure

The converter generates:
- **Markdown files** in `<output>/markdown/` organized by documentation category (symbols, articles, tutorials)
- **Link graph** at `<output>/linkgraph/adjacency.json` containing cross-document relationships
- **Structured index** and table of contents for navigation

### Input Requirements

- Input must be a **directory** (either a DocC bundle or a `.doccarchive` directory)
- If you have a `.doccarchive` **file**, extract it first using: `ditto MyDocs.doccarchive MyDocs.doccarchive-extracted`
- The DocC bundle must contain a valid `Info.plist` manifest

## Installation

### From Source (Swift 6.1.2+)

Clone the repository and build locally:

```bash
git clone git@github.com:SoundBlaster/docc2context.git
cd docc2context
swift build -c release
.build/release/docc2context --help
```

### From GitHub Releases

Binary releases are available for macOS (arm64/x86_64) and Linux (x86_64/aarch64):

```bash
# macOS
curl -L https://github.com/SoundBlaster/docc2context/releases/download/v<version>/docc2context-<version>-macos-arm64.tar.gz | tar xz
sudo mv docc2context /usr/local/bin/

# Linux
curl -L https://github.com/SoundBlaster/docc2context/releases/download/v<version>/docc2context-<version>-linux-x86_64.tar.gz | tar xz
sudo mv docc2context /usr/local/bin/
```

### Homebrew (macOS)

```bash
brew tap SoundBlaster/docc2context
brew install docc2context
```

## Self-Docs Artifacts

Every push to `main` automatically generates and uploads a self-docs artifact. This allows quick visual inspection of the converter output without running locally.

**To view the latest self-docs:**
1. Go to the [Actions tab](https://github.com/SoundBlaster/docc2context/actions/workflows/self-docs.yml)
2. Click the most recent "Generate Self-Docs Artifact" workflow run
3. Download the `docc2context-self-docs` artifact (Markdown files)
4. Optionally download `docc2context-link-graph` (link graph JSON)

The artifacts are generated from `Fixtures/Docc2contextCore.doccarchive`, so they reflect how the converter renders the self-documentation for the docc2context project itself. This provides a good baseline for comparing visual output quality and structure.

## Testing

Run the test suite locally:

```bash
swift test
```

With code coverage:

```bash
swift test --enable-code-coverage
python3 Scripts/enforce_coverage.py --threshold 88 --target Docc2contextCore=Sources/Docc2contextCore
```

Run release gates (determinism + coverage + fixture validation):

```bash
bash Scripts/release_gates.sh
```

## Development Documentation

- **Product Requirements**: `DOCS/PRD/docc2context_prd.md`
- **Workplan**: `DOCS/workplan.md`
- **Task Tracking**: `DOCS/todo.md`
- **Archive Summary**: `DOCS/TASK_ARCHIVE/ARCHIVE_SUMMARY.md`
- **Current State**: `DOCS/INPROGRESS/ACTUAL_STATE.md`
- **Fixtures**: `Fixtures/README.md`
