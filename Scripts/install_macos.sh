#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_BASE_URL="https://github.com/SoundBlaster/docc2context/releases/download"

log_step() {
  printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$1"
}

log_error() {
  printf '[%s][ERROR] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") --version <tag> [--arch arm64|x86_64] [--base-url <url>] [--download-dir <dir>] [--prefix <dir>] [--dry-run]

Options:
  --version       Required tag or version (accepts optional leading 'v', used in download URL).
  --arch          Target architecture (default: host output of uname -m, normalized to arm64/x86_64).
  --base-url      Base release URL (default: $DEFAULT_BASE_URL).
  --download-dir  Directory to stage downloads (default: temporary under .build/install-macos.*).
  --prefix        Installation prefix (default: /opt/homebrew for arm64, /usr/local for x86_64).
  --dry-run       Print planned operations without downloading or installing.
  -h, --help      Show this message.
USAGE
}

version=""
arch=""
base_url="$DEFAULT_BASE_URL"
download_dir=""
prefix=""
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
    --base-url)
      base_url="$2"
      shift 2
      ;;
    --download-dir)
      download_dir="$2"
      shift 2
      ;;
    --prefix)
      prefix="$2"
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
  log_error "Missing required --version argument"
  usage
  exit 1
fi

sanitize_version() {
  local raw="$1"
  local cleaned="${raw#v}"
  if [[ -z "$cleaned" ]]; then
    log_error "Version must contain at least one numeric component"
    exit 1
  fi
  echo "$cleaned"
}

normalize_arch() {
  local raw="$1"
  case "$raw" in
    arm64|aarch64)
      echo "arm64"
      ;;
    x86_64|amd64)
      echo "x86_64"
      ;;
    *)
      log_error "Unsupported architecture: $raw (expected arm64 or x86_64)"
      exit 1
      ;;
  esac
}

if [[ -z "$arch" ]]; then
  arch="$(uname -m)"
fi
arch="$(normalize_arch "$arch")"

if [[ -z "$prefix" ]]; then
  if [[ "$arch" == "arm64" ]]; then
    prefix="/opt/homebrew"
  else
    prefix="/usr/local"
  fi
fi

sanitized_version="$(sanitize_version "$version")"
version_tag="$version"
if [[ "$version_tag" != v* ]]; then
  version_tag="v${sanitized_version}"
fi

artifact_name="docc2context-v${sanitized_version}-macos-${arch}.zip"
checksum_name="${artifact_name}.sha256"
artifact_url="${base_url%/}/${version_tag}/${artifact_name}"
checksum_url="${base_url%/}/${version_tag}/${checksum_name}"
install_path="${prefix%/}/bin/docc2context"

if [[ -z "$download_dir" ]]; then
  download_dir="$(mktemp -d "$REPO_ROOT/.build/install-macos.XXXXXX")"
  cleanup_dir="$download_dir"
else
  mkdir -p "$download_dir"
  cleanup_dir=""
fi

cleanup() {
  if [[ -n "${cleanup_dir:-}" && -d "$cleanup_dir" ]]; then
    rm -rf "$cleanup_dir"
  fi
}
trap cleanup EXIT

log_step "Planned artifact: $artifact_name ($arch)"
log_step "Download URL: $artifact_url"
log_step "Checksum URL: $checksum_url"
log_step "Install destination: $install_path"

if [[ "$dry_run" == "1" ]]; then
  log_step "Dry run enabled; skipping download and install steps."
  exit 0
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "Required command '$1' is not available"
    exit 1
  fi
}

require_command curl
require_command unzip
require_command shasum
require_command install

zip_path="$download_dir/$artifact_name"
checksum_path="$download_dir/$checksum_name"

log_step "Downloading macOS zip..."
curl -fL "$artifact_url" -o "$zip_path"

log_step "Downloading checksum..."
curl -fL "$checksum_url" -o "$checksum_path"

log_step "Verifying checksum..."
(cd "$download_dir" && shasum -a 256 -c "$checksum_path")

stage_dir="$(mktemp -d "$download_dir/docc2context-unpack.XXXXXX")"
log_step "Unzipping to $stage_dir"
unzip -q "$zip_path" -d "$stage_dir"

bundle_dir="$(find "$stage_dir" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
if [[ -z "$bundle_dir" ]]; then
  bundle_dir="$stage_dir"
fi

if [[ ! -f "$bundle_dir/docc2context" ]]; then
  log_error "docc2context binary not found in extracted archive"
  exit 1
fi

mkdir -p "${install_path%/*}"
install -m 0755 "$bundle_dir/docc2context" "$install_path"

if [[ -f "$bundle_dir/README.md" ]]; then
  install -m 0644 "$bundle_dir/README.md" "${prefix%/}/README.md"
fi
if [[ -f "$bundle_dir/LICENSE" ]]; then
  install -m 0644 "$bundle_dir/LICENSE" "${prefix%/}/LICENSE"
fi

log_step "docc2context installed to $install_path"
