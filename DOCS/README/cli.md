# CLI

## Usage

`docc2context` converts a DocC bundle directory (for example `MyDocs.docc`) or a `.doccarchive` **directory** into deterministic Markdown and a link graph.

```text
docc2context <input-path> --output <directory> [--format markdown] [--force] [--technology <name>] [--symbol-layout tree|single]
```

## Options

- `<input-path>` – required; points to a DocC bundle directory (or a `.doccarchive` directory). If you have a `.doccarchive` file, extract it first.
- `--output <directory>` – required; target directory that will contain `markdown/` and `linkgraph/` outputs.
- `--force` – overwrite the output directory if it already exists.
- `--technology <name>` – filter symbols by technology/module name; can be repeated.
- `--symbol-layout tree|single` – symbol page output layout (`tree` default; `single` emits one `.md` per top-level symbol).

## Help

```bash
docc2context --help
```

