#!/usr/bin/env python3
"""Lightweight Markdown lint helper for README and selected docs."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
README_PATH = REPO_ROOT / "README.md"

REQUIRED_README_HEADINGS = [
    "## Quick start",
    "## More docs",
]

REQUIRED_README_SNIPPETS = [
    "swift run docc2context Fixtures/Docc2contextCore.doccarchive",
    "DOCS/README/",
]

REQUIRED_PROJECT_DOCS_SNIPPETS = [
    "Fixtures/manifest.json",
    "Scripts/validate_fixtures_manifest.py",
    "Scripts/release_gates.sh",
    "Scripts/package_release.sh",
    "swift test --enable-code-coverage",
    "python3 Scripts/enforce_coverage.py",
    "python3 Scripts/lint_markdown.py",
    "brew tap docc2context/tap",
    "install_macos.sh",
    "codesign",
    "notarytool",
]


def iter_markdown_paths(paths: list[str]) -> list[Path]:
    discovered: list[Path] = []
    for raw in paths:
        candidate = Path(raw)
        if not candidate.exists():
            raise FileNotFoundError(f"Path does not exist: {candidate}")
        if candidate.is_dir():
            for file_path in sorted(candidate.rglob("*.md")):
                if file_path.is_file():
                    discovered.append(file_path)
        else:
            discovered.append(candidate)
    return discovered or [README_PATH]


def lint_markdown(path: Path) -> list[str]:
    errors: list[str] = []
    text = path.read_text(encoding="utf-8")
    if "\r" in text:
        errors.append(f"{path}: contains CR line endings; convert to LF")
    for line_no, line in enumerate(text.splitlines(), start=1):
        if line.rstrip() != line:
            errors.append(f"{path}:{line_no}: trailing whitespace detected")
        if "\t" in line:
            errors.append(f"{path}:{line_no}: tab character detected; use spaces")
    if path.resolve() == README_PATH:
        errors.extend(check_readme(text))
    return errors


def check_readme(text: str) -> list[str]:
    errors: list[str] = []
    for heading in REQUIRED_README_HEADINGS:
        if heading not in text:
            errors.append(f"{README_PATH}: missing required heading '{heading}'")
    for snippet in REQUIRED_README_SNIPPETS:
        if snippet not in text:
            errors.append(f"{README_PATH}: missing required snippet '{snippet}'")
    return errors


def check_project_docs() -> list[str]:
    errors: list[str] = []
    docs_root = REPO_ROOT / "DOCS" / "README"
    if not docs_root.exists():
        return [f"{docs_root}: missing docs directory"]

    combined = []
    for file_path in sorted(docs_root.rglob("*.md")):
        if file_path.is_file():
            combined.append(file_path.read_text(encoding="utf-8"))
    combined_text = "\n\n".join(combined)

    for snippet in REQUIRED_PROJECT_DOCS_SNIPPETS:
        if snippet not in combined_text:
            errors.append(f"{docs_root}: missing required snippet '{snippet}'")
    return errors


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Lint Markdown files for docc2context")
    parser.add_argument(
        "paths",
        nargs="*",
        default=[str(README_PATH)],
        help="Markdown files or directories to lint (defaults to README.md)",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    try:
        markdown_paths = iter_markdown_paths(args.paths)
    except FileNotFoundError as exc:  # pragma: no cover - surfaced to CLI
        print(f"[lint] {exc}", file=sys.stderr)
        return 1

    failures: list[str] = []
    for md_path in markdown_paths:
        failures.extend(lint_markdown(md_path))

    failures.extend(check_project_docs())

    if failures:
        for failure in failures:
            print(f"[lint] {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":  # pragma: no cover - CLI entrypoint
    raise SystemExit(main(sys.argv[1:]))
