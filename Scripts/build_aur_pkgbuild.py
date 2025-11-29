#!/usr/bin/env python3
"""
Generate an Arch Linux PKGBUILD that consumes released docc2context tarballs.

This helper stays offline-friendly by templating the PKGBUILD from provided
URLs and checksums without invoking network operations.
"""

import argparse
from pathlib import Path
import sys
import textwrap


def normalize_version(version: str) -> str:
    return version[1:] if version.startswith("v") else version


def build_pkgbuild(args: argparse.Namespace) -> str:
    pkgver = normalize_version(args.version)
    pkgbuild = f"""# Maintainer: docc2context maintainers <maintainers@docc2context.invalid>
pkgname=docc2context
pkgver={pkgver}
pkgrel={args.pkgrel}
pkgdesc="Convert DocC bundles to deterministic Markdown and link graphs"
arch=('x86_64' 'aarch64')
url="https://github.com/SoundBlaster/docc2context"
license=('MIT')
depends=('glibc')
provides=('docc2context')
conflicts=('docc2context-bin')
source_x86_64=('{args.x86_64_url}')
sha256sums_x86_64=('{args.x86_64_sha256}')
source_aarch64=('{args.aarch64_url}')
sha256sums_aarch64=('{args.aarch64_sha256}')
options=('!strip')

prepare() {{
  mkdir -p "$srcdir/extracted"
}}

build() {{
  return 0
}}

package() {{
  local archive
  case "$CARCH" in
    x86_64)
      archive="$(basename "{args.x86_64_url}")"
      ;;
    aarch64)
      archive="$(basename "{args.aarch64_url}")"
      ;;
    *)
      echo "Unsupported architecture: $CARCH" >&2
      return 1
      ;;
  esac

  bsdtar -xf "$srcdir/$archive" -C "$srcdir/extracted"
  local staged_dir="$srcdir/extracted/docc2context-v${{pkgver}}"
  install -Dm755 "$staged_dir/docc2context" "$pkgdir/usr/local/bin/docc2context"
  install -Dm644 "$staged_dir/README.md" "$pkgdir/usr/share/doc/docc2context/README.md"
  install -Dm644 "$staged_dir/LICENSE" "$pkgdir/usr/share/doc/docc2context/LICENSE"
}}
"""
    return textwrap.dedent(pkgbuild)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a PKGBUILD for docc2context")
    parser.add_argument("--version", required=True, help="Semantic version (with or without leading v)")
    parser.add_argument("--pkgrel", default="1", help="Arch package release number")
    parser.add_argument("--x86_64-url", required=True, help="URL to the x86_64 Linux tarball")
    parser.add_argument("--x86_64-sha256", required=True, help="SHA256 checksum for the x86_64 tarball")
    parser.add_argument("--aarch64-url", required=True, help="URL to the aarch64 Linux tarball")
    parser.add_argument("--aarch64-sha256", required=True, help="SHA256 checksum for the aarch64 tarball")
    parser.add_argument("--output", required=True, help="Destination path for the generated PKGBUILD")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    output_path = Path(args.output)
    content = build_pkgbuild(args)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
