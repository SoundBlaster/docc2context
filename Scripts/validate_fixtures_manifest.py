#!/usr/bin/env python3
"""Validate Fixtures/manifest.json entries for release gating."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any, Dict, Iterable


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate fixture manifest contents")
    parser.add_argument("manifest", help="Path to Fixtures/manifest.json")
    return parser.parse_args()


def iter_files(path: Path) -> Iterable[Path]:
    if path.is_file():
        yield path
        return
    for child in sorted(path.rglob("*")):
        if child.is_file():
            yield child


def sha256_for(path: Path) -> str:
    digest = hashlib.sha256()
    for file_path in iter_files(path):
        digest.update(file_path.read_bytes())
    return digest.hexdigest()


def byte_size(path: Path) -> int:
    return sum(file_path.stat().st_size for file_path in iter_files(path))


def is_populated(bundle: Dict[str, Any]) -> bool:
    for key in ("id", "name", "relative_path"):
        value = str(bundle.get(key, "")).strip()
        if value:
            return True
    return False


def main() -> int:
    args = parse_args()
    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        print(f"[ERROR] Manifest not found: {manifest_path}", file=sys.stderr)
        return 1

    try:
        data = json.loads(manifest_path.read_text())
    except json.JSONDecodeError as exc:
        print(f"[ERROR] Invalid JSON in {manifest_path}: {exc}", file=sys.stderr)
        return 1

    bundles = data.get("bundles", [])
    populated = [bundle for bundle in bundles if is_populated(bundle)]
    if not populated:
        print(
            f"[WARN] {manifest_path} contains no populated bundle entries; fixture population pending task A3."
        )
        return 0

    failures = 0
    fixtures_root = manifest_path.parent
    for bundle in populated:
        bundle_id = bundle.get("id") or bundle.get("name") or "<unknown>"
        required_fields = ["id", "name", "relative_path", "type", "checksum", "size_bytes"]
        missing = [field for field in required_fields if field not in bundle or bundle[field] in (None, "")]
        if missing:
            print(f"[ERROR] Bundle '{bundle_id}' missing fields: {', '.join(missing)}", file=sys.stderr)
            failures += 1
            continue

        archive_path = fixtures_root / bundle["relative_path"]
        if not archive_path.exists():
            print(f"[ERROR] Bundle '{bundle_id}' missing at {archive_path}", file=sys.stderr)
            failures += 1
            continue

        checksum = bundle.get("checksum", {})
        algorithm = (checksum.get("algorithm") or "").lower()
        value = (checksum.get("value") or "").lower()
        if algorithm != "sha256" or not value:
            print(
                f"[ERROR] Bundle '{bundle_id}' must declare a sha256 checksum value; found '{algorithm}'",
                file=sys.stderr,
            )
            failures += 1
        else:
            digest = sha256_for(archive_path)
            if digest != value:
                print(
                    f"[ERROR] Bundle '{bundle_id}' checksum mismatch: expected {value}, computed {digest}",
                    file=sys.stderr,
                )
                failures += 1

        try:
            expected_size = int(bundle.get("size_bytes", 0))
        except (TypeError, ValueError):
            print(f"[ERROR] Bundle '{bundle_id}' has invalid size_bytes field", file=sys.stderr)
            failures += 1
            continue

        actual_size = byte_size(archive_path)
        if expected_size and expected_size != actual_size:
            print(
                f"[ERROR] Bundle '{bundle_id}' size mismatch: expected {expected_size}, got {actual_size}",
                file=sys.stderr,
            )
            failures += 1
        elif expected_size == 0:
            print(f"[WARN] Bundle '{bundle_id}' size_bytes is 0; consider updating the manifest.")

    if failures:
        return 1

    print(f"[OK] Validated {len(populated)} fixture bundle(s) declared in {manifest_path}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
