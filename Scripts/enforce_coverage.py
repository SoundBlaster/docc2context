#!/usr/bin/env python3
"""Enforce minimum line coverage for Swift targets using llvm-cov export output."""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


@dataclass
class CoverageTotals:
    covered: int
    total: int

    @property
    def percent(self) -> float:
        if self.total == 0:
            return 0.0
        return (self.covered / self.total) * 100.0


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def resolve_llvm_cov() -> str:
    env_override = os.environ.get("LLVM_COV")
    if env_override:
        candidate = shutil.which(env_override) if not os.path.isabs(env_override) else env_override
        if candidate and Path(candidate).exists():
            return str(candidate)

    path_candidate = shutil.which("llvm-cov")
    if path_candidate:
        return path_candidate

    swiftc = shutil.which("swiftc")
    if swiftc:
        swiftc_path = Path(swiftc).resolve()
        candidates = [
            swiftc_path.parent / "llvm-cov",
            swiftc_path.parent.parent / "usr/bin/llvm-cov",
            swiftc_path.parent.parent / "bin/llvm-cov",
        ]
        for candidate in candidates:
            if candidate.exists():
                return str(candidate)

    raise SystemExit("Unable to locate llvm-cov. Set LLVM_COV or add it to PATH.")


def default_profdata_path(root: Path) -> Path:
    return root / ".build" / "debug" / "codecov" / "default.profdata"


def find_test_binary(root: Path) -> Path:
    candidates = sorted(root.glob(".build/**/*.xctest"))
    for candidate in candidates:
        if candidate.name == "docc2contextPackageTests.xctest":
            return resolve_executable_path(candidate)
    raise SystemExit("Unable to locate docc2contextPackageTests.xctest in .build directory.")


def resolve_executable_path(path: Path) -> Path:
    if path.is_file():
        return path

    bundle_binary_dir = path / "Contents" / "MacOS"
    if bundle_binary_dir.is_dir():
        stem_candidate = bundle_binary_dir / path.stem
        if stem_candidate.is_file():
            return stem_candidate

        binaries = [candidate for candidate in bundle_binary_dir.iterdir() if candidate.is_file()]
        if len(binaries) == 1:
            return binaries[0]

        if binaries:
            raise SystemExit(
                f"Unable to disambiguate binary inside bundle {path}. Candidates: {', '.join(b.name for b in binaries)}"
            )

    raise SystemExit(f"Unable to locate executable binary inside {path}")


def load_coverage_json(llvm_cov: str, profdata: Path, binary: Path) -> Dict:
    try:
        result = subprocess.run(
            [
                llvm_cov,
                "export",
                "-summary-only",
                "-instr-profile",
                str(profdata),
                str(binary),
            ],
            capture_output=True,
            check=True,
            text=True,
        )
    except subprocess.CalledProcessError as exc:  # pragma: no cover - surfaced to caller
        sys.stderr.write(exc.stderr)
        raise SystemExit(exc.returncode)
    return json.loads(result.stdout)


def aggregate_totals(data: Dict, targets: Dict[str, Path]) -> Dict[str, CoverageTotals]:
    files = data.get("data", [{}])[0].get("files", [])
    totals: Dict[str, CoverageTotals] = {name: CoverageTotals(covered=0, total=0) for name in targets}
    root = repo_root()

    for file_entry in files:
        filename = Path(file_entry.get("filename", ""))
        try:
            relative = filename.resolve().relative_to(root)
        except Exception:
            continue

        summary = file_entry.get("summary", {})
        lines = summary.get("lines", {})
        count = int(lines.get("count", 0))
        covered = int(lines.get("covered", 0))
        if count == 0:
            continue

        for name, prefix in targets.items():
            if relative.as_posix().startswith(prefix.as_posix()):
                totals[name].covered += covered
                totals[name].total += count
                break

    return totals


def parse_target_args(values: Iterable[str]) -> Dict[str, Path]:
    targets: Dict[str, Path] = {}
    for value in values:
        if "=" not in value:
            raise SystemExit(f"Invalid --target value '{value}'. Expected format name=path-prefix")
        name, prefix = value.split("=", 1)
        name = name.strip()
        prefix = prefix.strip()
        if not name or not prefix:
            raise SystemExit(f"Invalid --target value '{value}'.")
        targets[name] = Path(prefix)
    return targets


def main(argv: List[str]) -> int:
    parser = argparse.ArgumentParser(description="Enforce minimum Swift coverage per target")
    parser.add_argument("--profdata", type=Path, default=None, help="Path to default.profdata")
    parser.add_argument("--binary", type=Path, default=None, help="Path to docc2contextPackageTests.xctest")
    parser.add_argument("--threshold", type=float, default=90.0, help="Required minimum line coverage percentage")
    parser.add_argument(
        "--target",
        action="append",
        help="Target specification in the form name=relative/source/prefix. Defaults to docc2context targets.",
    )

    args = parser.parse_args(argv)
    root = repo_root()

    profdata = args.profdata or default_profdata_path(root)
    if not profdata.exists():
        raise SystemExit(f"Coverage data not found at {profdata}")

    binary = args.binary or find_test_binary(root)
    if not binary.exists():
        raise SystemExit(f"Test bundle not found at {binary}")

    if args.target:
        targets = parse_target_args(args.target)
    else:
        targets = {
            "Docc2contextCore": Path("Sources/Docc2contextCore"),
            "docc2context": Path("Sources/docc2context"),
        }

    llvm_cov = resolve_llvm_cov()
    data = load_coverage_json(llvm_cov, profdata, binary)
    totals = aggregate_totals(data, targets)

    print(f"Coverage threshold: {args.threshold:.1f}%")
    epsilon = 0.005  # tolerate rounding to hundredths of a percent
    failures: List[Tuple[str, CoverageTotals]] = []
    for name, total in totals.items():
        percent = total.percent
        print(
            f"  {name}: {percent:.2f}% (covered {total.covered} of {total.total} lines)"
        )
        if percent + epsilon < args.threshold:
            failures.append((name, total))

    if failures:
        failing_text = ", ".join(f"{name} ({total.percent:.2f}%)" for name, total in failures)
        raise SystemExit(f"Coverage below threshold for: {failing_text}")

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
