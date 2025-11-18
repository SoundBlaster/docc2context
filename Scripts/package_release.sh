#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_OUTPUT_DIR="$REPO_ROOT/dist"
RELEASE_GATES_SCRIPT=${RELEASE_GATES_SCRIPT:-"$SCRIPT_DIR/release_gates.sh"}
PACKAGE_RELEASE_SKIP_GATES=${PACKAGE_RELEASE_SKIP_GATES:-"0"}
SWIFT_BUILD_FLAGS_RAW=${PACKAGE_RELEASE_SWIFT_BUILD_FLAGS:-""}
BUILD_CONFIGURATION=${PACKAGE_RELEASE_BUILD_CONFIGURATION:-"release"}

log_step() {
  printf '\n[%s] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

log_warn() {
  printf '\n[%s][WARN] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

log_error() {
  printf '\n[%s][ERROR] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") --version <semver> [--platform linux|macos] [--output <dir>] [--dry-run]

Options:
  --version     Required semantic version or tag (accepts optional leading 'v').
  --platform    Target platform identifier (linux or macos). Defaults to host platform.
  --output      Directory for the packaged artifacts. Defaults to $DEFAULT_OUTPUT_DIR.
  --dry-run     Performs the full build/package flow but marks artifacts as dry-run only.
  -h, --help    Print this message.
USAGE
}

version=""
platform=""
output_dir="$DEFAULT_OUTPUT_DIR"
dry_run="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      version="$2"
      shift 2
      ;;
    --platform)
      platform="$2"
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
  log_error "Missing required --version option"
  usage
  exit 1
fi

sanitized_version="${version#v}"
if [[ -z "$sanitized_version" || ! "$sanitized_version" =~ ^[0-9]+(\.[0-9A-Za-z-]+)*$ ]]; then
  log_error "Version '$version' is not a valid semantic version"
  exit 1
fi

if [[ -z "$platform" ]]; then
  uname_out="$(uname -s)"
  case "$uname_out" in
    Linux)
      platform="linux"
      ;;
    Darwin)
      platform="macos"
      ;;
    *)
      log_error "Unsupported host platform '$uname_out'. Specify --platform explicitly."
      exit 1
      ;;
  esac
fi

if [[ "$platform" != "linux" && "$platform" != "macos" ]]; then
  log_error "Unsupported --platform value '$platform'"
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  log_error "zip command not available"
  exit 1
fi

if ! command -v shasum >/dev/null 2>&1; then
  log_error "shasum command not available"
  exit 1
fi

mkdir -p "$output_dir"

cleanup_dir=""
cleanup() {
  if [[ -n "$cleanup_dir" && -d "$cleanup_dir" ]]; then
    rm -rf "$cleanup_dir"
  fi
}
trap cleanup EXIT

run_release_gates() {
  if [[ "$PACKAGE_RELEASE_SKIP_GATES" == "1" ]]; then
    log_warn "Skipping release gates (PACKAGE_RELEASE_SKIP_GATES=1)"
    return
  fi
  if [[ ! -x "$RELEASE_GATES_SCRIPT" ]]; then
    log_error "Release gates script not executable at $RELEASE_GATES_SCRIPT"
    exit 1
  fi
  log_step "Running release gates via $RELEASE_GATES_SCRIPT"
  bash "$RELEASE_GATES_SCRIPT"
}

build_binary() {
  if [[ -n "${PACKAGE_RELEASE_BINARY_OVERRIDE:-}" ]]; then
    if [[ ! -f "$PACKAGE_RELEASE_BINARY_OVERRIDE" ]]; then
      log_error "PACKAGE_RELEASE_BINARY_OVERRIDE does not exist: $PACKAGE_RELEASE_BINARY_OVERRIDE"
      exit 1
    fi
    log_warn "Using prebuilt binary at $PACKAGE_RELEASE_BINARY_OVERRIDE"
    echo "$PACKAGE_RELEASE_BINARY_OVERRIDE"
    return
  fi

  log_step "Building docc2context in ${BUILD_CONFIGURATION} configuration"
  log_step "Resolving binary path via swift build"
  local build_cmd=("swift" "build" "-c" "${BUILD_CONFIGURATION}" "--product" "docc2context")
  if [[ -n "$SWIFT_BUILD_FLAGS_RAW" ]]; then
    local extra_flags=()
    read -r -a extra_flags <<<"$SWIFT_BUILD_FLAGS_RAW"
    build_cmd+=("${extra_flags[@]}")
  fi
  build_cmd+=("--show-bin-path")
  local bin_path
  bin_path="$(${build_cmd[@]})"
  if [[ ! -d "$bin_path" ]]; then
    log_error "Unable to locate Swift build output directory"
    exit 1
  fi
  local binary="$bin_path/docc2context"
  if [[ ! -f "$binary" ]]; then
    log_error "docc2context binary not found at $binary"
    exit 1
  fi

  if [[ "$platform" == "macos" && -n "${MACOS_SIGN_IDENTITY:-}" ]]; then
    log_step "Codesigning macOS binary with identity $MACOS_SIGN_IDENTITY"
    codesign --force --options runtime --timestamp --sign "$MACOS_SIGN_IDENTITY" "$binary"
  fi

  echo "$binary"
}

stage_artifacts() {
  cleanup_dir="$(mktemp -d "$REPO_ROOT/.build/package-release.XXXXXX")"
  local stage_dir="$cleanup_dir/docc2context-v${sanitized_version}"
  mkdir -p "$stage_dir"
  cp "$1" "$stage_dir/docc2context"
  chmod +x "$stage_dir/docc2context"
  cp "$REPO_ROOT/README.md" "$stage_dir/README.md"
  cp "$REPO_ROOT/LICENSE" "$stage_dir/LICENSE"
  echo "$stage_dir"
}

package_release() {
  local stage_dir="$1"
  local artifact_name="docc2context-v${sanitized_version}-${platform}"
  if [[ "$dry_run" == "1" ]]; then
    artifact_name+="-dryrun"
  fi
  local artifact_zip="$output_dir/${artifact_name}.zip"
  (cd "$(dirname "$stage_dir")" && zip -rq "$artifact_zip" "$(basename "$stage_dir")")
  log_step "Created artifact: $artifact_zip"
  local checksum_file="$artifact_zip.sha256"
  shasum -a 256 "$artifact_zip" > "$checksum_file"
  log_step "Wrote checksum: $checksum_file"

  local summary_file="$output_dir/${artifact_name}.md"
  {
    echo "# docc2context Release Summary"
    echo "- Version: $sanitized_version"
    echo "- Platform: $platform"
    echo "- Artifact: $(basename "$artifact_zip")"
    echo "- Checksum File: $(basename "$checksum_file")"
    echo "- Release Gates: $([[ "$PACKAGE_RELEASE_SKIP_GATES" == "1" ]] && echo "SKIPPED" || echo "PASSED")"
    echo "- Dry Run: $([[ "$dry_run" == "1" ]] && echo "true" || echo "false")"
    echo "- Generated At: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$summary_file"
  log_step "Recorded summary: $summary_file"
}

main() {
  run_release_gates
  local binary_path
  binary_path="$(build_binary)"
  local stage_dir
  stage_dir="$(stage_artifacts "$binary_path")"
  package_release "$stage_dir"
  log_step "Packaging complete"
}

main
