#!/usr/bin/env python3
"""Generate a deterministic Homebrew formula for docc2context."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render a Homebrew formula that references architecture-specific macOS artifacts."
    )
    parser.add_argument("--version", required=True, help="Semantic version (accepts optional leading 'v').")
    parser.add_argument("--arm64-url", required=True, help="Download URL for the arm64 macOS zip artifact.")
    parser.add_argument("--arm64-sha256", required=True, help="SHA256 checksum for the arm64 artifact.")
    parser.add_argument("--x86_64-url", required=True, help="Download URL for the x86_64 macOS zip artifact.")
    parser.add_argument("--x86_64-sha256", required=True, help="SHA256 checksum for the x86_64 artifact.")
    parser.add_argument("--output", required=True, help="Destination file path for the rendered formula.")
    return parser.parse_args()


def sanitize_version(raw: str) -> str:
    sanitized = raw.lstrip("v")
    if not sanitized:
        raise ValueError("Version must contain at least one numeric component")
    return sanitized


def render_formula(version: str, arm64_url: str, arm64_sha: str, x86_url: str, x86_sha: str) -> str:
    template = """class Docc2context < Formula
  desc "Convert DocC bundles to deterministic Markdown plus link graphs"
  homepage "https://github.com/docc2context/docc2context"
  version "{version}"
  license "MIT"

  on_macos do
    on_arm do
      url "{arm64_url}"
      sha256 "{arm64_sha}"
    end

    on_intel do
      url "{x86_url}"
      sha256 "{x86_sha}"
    end
  end

  def install
    bin.install "docc2context"
    prefix.install "README.md", "LICENSE"
  end

  test do
    assert_match version.to_s, shell_output("#{{bin}}/docc2context --version")
  end
end
"""
    return template.format(
        version=version,
        arm64_url=arm64_url,
        arm64_sha=arm64_sha,
        x86_url=x86_url,
        x86_sha=x86_sha,
    )


def main() -> int:
    args = parse_args()
    try:
        sanitized_version = sanitize_version(args.version)
    except ValueError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1

    formula_contents = render_formula(
        sanitized_version,
        args.arm64_url,
        args.arm64_sha256,
        args.x86_64_url,
        args.x86_64_sha256,
    )

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(formula_contents, encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
