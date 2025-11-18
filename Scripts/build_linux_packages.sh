#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

log_step() {
  printf '\n[%s] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

log_error() {
  printf '\n[%s][ERROR] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

log_warn() {
  printf '\n[%s][WARN] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") --version <semver> --arch <arch> --stage-dir <dir> --binary <path> --output <dir> [--dry-run]

Options:
  --version    Semantic version number (without the leading 'v').
  --arch       Target CPU architecture (e.g., x86_64, aarch64).
  --stage-dir  Directory produced by package_release.sh that already contains docc2context + README + LICENSE.
  --binary     Absolute path to the compiled docc2context binary.
  --output     Destination directory for the generated artifacts.
  --dry-run    Append the -dryrun suffix to every artifact name.
  -h, --help   Show this help text.
USAGE
}

version=""
arch=""
stage_dir=""
binary_path=""
output_dir="$REPO_ROOT/dist"
dry_run="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      version="$2"
      shift 2
      ;;
    --arch)
      arch="$2"
      shift 2
      ;;
    --stage-dir)
      stage_dir="$2"
      shift 2
      ;;
    --binary)
      binary_path="$2"
      shift 2
      ;;
    --output)
      output_dir="$2"
      shift 2
      ;;
    --dry-run)
      dry_run="1"
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$version" ]]; then
  log_error "--version is required"
  usage
  exit 1
fi

sanitized_version="${version#v}"
if [[ -z "$sanitized_version" ]]; then
  log_error "Version must contain at least one numeric component"
  exit 1
fi
rpm_safe_version="${sanitized_version//-/_}"

if [[ -z "$arch" ]]; then
  log_error "--arch is required"
  usage
  exit 1
fi

if [[ ! -d "$stage_dir" ]]; then
  log_error "Stage directory not found: $stage_dir"
  exit 1
fi

if [[ ! -f "$binary_path" ]]; then
  log_error "Binary not found at $binary_path"
  exit 1
fi

mkdir -p "$output_dir"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "Required command '$1' is not available"
    exit 1
  fi
}

require_command tar
require_command gzip
require_command shasum
require_command dpkg-deb
require_command rpmbuild

normalize_arch() {
  local raw="$1"
  case "$raw" in
    x86_64|amd64)
      echo "x86_64"
      ;;
    arm64|aarch64)
      echo "aarch64"
      ;;
    *)
      echo "$raw"
      ;;
  esac
}

map_deb_arch() {
  local raw="$1"
  case "$raw" in
    x86_64|amd64)
      echo "amd64"
      ;;
    arm64|aarch64)
      echo "arm64"
      ;;
    *)
      log_error "Unsupported architecture for Debian package: $raw"
      exit 1
      ;;
  esac
}

map_rpm_arch() {
  local raw="$1"
  case "$raw" in
    x86_64|amd64)
      echo "x86_64"
      ;;
    arm64|aarch64)
      echo "aarch64"
      ;;
    *)
      log_error "Unsupported architecture for RPM package: $raw"
      exit 1
      ;;
  esac
}

suffix=""
if [[ "$dry_run" == "1" ]]; then
  suffix="-dryrun"
fi

artifact_paths=()

temp_root="$(mktemp -d "$REPO_ROOT/.build/linux-packages.XXXXXX")"
cleanup() {
  if [[ -d "$temp_root" ]]; then
    rm -rf "$temp_root"
  fi
}
trap cleanup EXIT

create_checksum() {
  local artifact="$1"
  local checksum_file="${artifact}.sha256"
  shasum -a 256 "$artifact" > "$checksum_file"
  log_step "Wrote checksum: $checksum_file"
}

create_tarball() {
  local normalized_arch
  normalized_arch="$(normalize_arch "$arch")"
  local tarball_name="docc2context-${sanitized_version}-linux-${normalized_arch}${suffix}.tar.gz"
  local tarball_path="$output_dir/$tarball_name"
  (cd "$(dirname "$stage_dir")" && tar -czf "$tarball_path" "$(basename "$stage_dir")")
  log_step "Created tarball: $tarball_path"
  create_checksum "$tarball_path"
  artifact_paths+=("$tarball_path")
}

create_deb_package() {
  local deb_arch
  deb_arch="$(map_deb_arch "$arch")"
  local deb_dir="$temp_root/deb"
  mkdir -p "$deb_dir/DEBIAN"
  mkdir -p "$deb_dir/usr/local/bin"
  mkdir -p "$deb_dir/usr/share/doc/docc2context"
  cp "$binary_path" "$deb_dir/usr/local/bin/docc2context"
  chmod 755 "$deb_dir/usr/local/bin/docc2context"
  cp "$stage_dir/README.md" "$deb_dir/usr/share/doc/docc2context/README.md"
  cp "$stage_dir/LICENSE" "$deb_dir/usr/share/doc/docc2context/LICENSE"
  cat > "$deb_dir/DEBIAN/control" <<CONTROL
Package: docc2context
Version: ${sanitized_version}
Section: utils
Priority: optional
Architecture: ${deb_arch}
Maintainer: docc2context maintainers <maintainers@docc2context.invalid>
Description: docc2context converts DocC bundles into deterministic Markdown for LLM ingestion.
Homepage: https://github.com/docc2context/docc2context
License: MIT
CONTROL
  local deb_name="docc2context_${sanitized_version}_linux_${deb_arch}${suffix}.deb"
  local deb_path="$output_dir/$deb_name"
  dpkg-deb --build "$deb_dir" "$deb_path" >/dev/null
  log_step "Created Debian package: $deb_path"
  create_checksum "$deb_path"
  artifact_paths+=("$deb_path")
}

create_rpm_package() {
  local rpm_arch
  rpm_arch="$(map_rpm_arch "$arch")"
  local rpm_version="$rpm_safe_version"
  local rpm_top="$temp_root/rpm"
  mkdir -p "$rpm_top/BUILD" "$rpm_top/RPMS" "$rpm_top/SOURCES" "$rpm_top/SPECS" "$rpm_top/SRPMS"
  local source_root="$temp_root/rpm-source/docc2context-source"
  mkdir -p "$source_root"
  cp "$stage_dir/docc2context" "$source_root/docc2context"
  chmod 755 "$source_root/docc2context"
  cp "$stage_dir/README.md" "$source_root/README.md"
  cp "$stage_dir/LICENSE" "$source_root/LICENSE"
  local source_tar="$rpm_top/SOURCES/docc2context-source.tar.gz"
  (cd "$(dirname "$source_root")" && tar -czf "$source_tar" "$(basename "$source_root")")

  local spec_file="$rpm_top/SPECS/docc2context.spec"
  cat > "$spec_file" <<SPEC
Name: docc2context
Version: ${rpm_version}
Release: 1
Summary: Convert DocC bundles into deterministic Markdown.
License: MIT
URL: https://github.com/docc2context/docc2context
Source0: docc2context-source.tar.gz
BuildArch: ${rpm_arch}

%description
Docc2context converts DocC bundles and archives into deterministic Markdown and link graphs for downstream tooling.

%prep
%setup -q -n docc2context-source

%build
# No build step required; the binary is supplied by the caller.

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/local/bin
install -m 0755 docc2context %{buildroot}/usr/local/bin/docc2context
mkdir -p %{buildroot}/usr/share/doc/docc2context
install -m 0644 README.md %{buildroot}/usr/share/doc/docc2context/README.md
install -m 0644 LICENSE %{buildroot}/usr/share/doc/docc2context/LICENSE

%files
/usr/local/bin/docc2context
/usr/share/doc/docc2context/README.md
/usr/share/doc/docc2context/LICENSE

%changelog
* $(date +"%a %b %d %Y") docc2context maintainers <maintainers@docc2context.invalid> - ${rpm_version}-1
- Automated package build
SPEC

  rpmbuild --quiet --define "_topdir $rpm_top" -bb "$spec_file"
  local rpm_path="$rpm_top/RPMS/${rpm_arch}/docc2context-${rpm_version}-1.${rpm_arch}.rpm"
  if [[ ! -f "$rpm_path" ]]; then
    log_error "rpmbuild did not produce expected RPM at $rpm_path"
    exit 1
  fi
  local dest_rpm="docc2context-${sanitized_version}-linux-${rpm_arch}${suffix}.rpm"
  local dest_path="$output_dir/$dest_rpm"
  cp "$rpm_path" "$dest_path"
  log_step "Created RPM package: $dest_path"
  create_checksum "$dest_path"
  artifact_paths+=("$dest_path")
}

create_tarball
create_deb_package
create_rpm_package

for artifact in "${artifact_paths[@]}"; do
  echo "$artifact"
done
