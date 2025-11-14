# docc2context

`docc2context` is a Swift command-line utility that converts DocC bundles and archives into deterministic Markdown chunks plus link graphs for LLM ingestion. The package currently contains a CLI target (`docc2context`), a reusable core library, and unit tests wired through Swift Package Manager.

## Development quick start

### 1. Install Swift

Swift 6.1.2 is the baseline toolchain for this repo. On macOS, install or select Xcode 16.4 (the version our CI pins) so the bundled Swift 6.1.2 SDK matches the GitHub runners. On Linux, download the Swift 6.1.2 release for Ubuntu 22.04 (or your distro) from [Swift.org](https://swift.org/download/).

For Ubuntu 22.04 the basic setup looks like:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y clang libicu-dev libatomic1 libcurl4-openssl-dev
# download & unpack Swift toolchain from swift.org, then add it to PATH
export PATH=/opt/swift/usr/bin:$PATH  # adjust for your install prefix
```

### 2. Validate the toolchain

Confirm Swift is discoverable and matches the expected version:

```bash
swift --version
# should contain "6.1.2"
```

### 3. Build & test locally

Use SwiftPM for everyday workflows:

```bash
swift build
swift test
```

The tests exercise the CLI target and keep the Linux/macOS builds honest.

## CLI usage (bootstrap)

The current CLI exposes the argument contract verified by the initial CLI test suite so downstream implementation work has a stable spec.

```
docc2context <input-path> --output <directory> [--format markdown] [--force]
```

- `<input-path>` – Required positional argument that points to a DocC bundle or `.doccarchive` to convert.
- `--output <directory>` – Required option describing where Markdown/link graph artifacts should be written.
- `--format <value>` – Optional output format selector. For now only `markdown` is accepted; other values exit with code 64 and
  include the supported list in the error text.
- `--force` – Optional boolean flag that indicates the output directory may be overwritten when later stages implement file sys
  tem writes.

Parsing errors exit with `EX_USAGE`/64 and human-readable guidance so scripts can detect misconfigurations early. `--help` print
s the same usage and documents each supported flag.

## Metadata parsing pipeline

`DoccMetadataParser` in the core library currently covers every metadata artifact that ships with DocC bundles so downstream Markdown rendering has strongly typed inputs without needing additional CLI flags. The parser expects the B3 input detection stage (and eventually the B4 archive extractor) to hand it a normalized bundle directory; within that directory it loads:

- `Info.plist` for bundle identifiers, localized display names, technology roots, and optional DocC/project version strings with typed errors for missing keys or invalid field types.
- `data/metadata/metadata.json` for render metadata describing generator details and format versions.
- `data/documentation/<TechnologyRoot>.json` for technology overview nodes, including abstracts and topic identifiers used to seed Markdown navigation.
- `data/symbol-graphs/*.json` for symbol references that are sorted deterministically by identifier/module names so later phases produce stable Markdown regardless of filesystem ordering.

These entry points power the `MetadataParsingTests` suite, which reads both tutorial and article fixtures to validate the behavior today while B6+ tasks wire the data into Markdown generation.

## Continuous Integration

GitHub Actions runs `swift build` and `swift test` on Ubuntu 22.04 and macOS. The Linux job relies on [`SwiftyLab/setup-swift`](https://github.com/SwiftyLab/setup-swift) to install Swift 6.1.2 and mirrors the package dependencies called out above so local and CI environments stay aligned. The macOS job selects Xcode 16.4 and uses its bundled Swift 6.1.2 toolchain to avoid mismatched SDK headers.

## Release gates

Run `Scripts/release_gates.sh` before tagging a release (or opening a PR) to exercise the same checks our CI gate will enforce:

```bash
Scripts/release_gates.sh
```

The script performs three steps:

1. Executes `swift test` to ensure the package is healthy on the local toolchain.
2. Runs a deterministic smoke test twice (defaults to `swift run docc2context --help`) and compares the SHA-256 hashes of the outputs. Override the command with `DETERMINISM_COMMAND="swift run docc2context --help --format markdown" Scripts/release_gates.sh` as more conversion paths come online.
3. Validates `Fixtures/manifest.json` via `Scripts/validate_fixtures_manifest.py`, confirming that every listed bundle exists, matches the recorded checksum, and reports the expected byte size. Until task A3 lands real fixtures, the validator logs a warning and exits successfully.

All steps must succeed for the script to exit 0, making it suitable for CI wiring or pre-push hooks.

## Project documentation

Roadmap planning, task coordination, and historical notes live under the `DOCS/` directory (e.g., `DOCS/workplan.md`, `DOCS/todo.md`, and `DOCS/INPROGRESS/`). Consult those files for the latest status instead of treating this README as a task tracker.
