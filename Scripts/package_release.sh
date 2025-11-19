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
Usage: $(basename "$0") --version <semver> [--platform linux|macos] [--arch <value>] [--output <dir>] [--dry-run]

Options:
  --version     Required semantic version or tag (accepts optional leading 'v').
  --platform    Target platform identifier (linux or macos). Defaults to host platform.
  --arch        CPU architecture (defaults to host \`uname -m\`).
  --output      Directory for the packaged artifacts. Defaults to $DEFAULT_OUTPUT_DIR.
  --dry-run     Performs the full build/package flow but marks artifacts as dry-run only.
  -h, --help    Print this message.
USAGE
}

version=""
platform=""
arch=""
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
    --arch)
      arch="$2"
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

if [[ -z "$arch" ]]; then
  arch="$(uname -m)"
fi

if [[ "$platform" != "linux" && "$platform" != "macos" ]]; then
  log_error "Unsupported --platform value '$platform'"
  exit 1
fi

normalize_macos_arch() {
  local raw="$1"
  case "$raw" in
    arm64|aarch64)
      echo "arm64"
      ;;
    x86_64|amd64)
      echo "x86_64"
      ;;
    *)
      log_error "Unsupported macOS architecture '$raw' (expected arm64 or x86_64)"
      exit 1
      ;;
  esac
}

if [[ "$platform" == "macos" ]]; then
  arch="$(normalize_macos_arch "$arch")"
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

create_summary() {
  local artifacts=("$@")
  local summary_suffix="$platform"
  if [[ -n "$arch" ]]; then
    summary_suffix+="-$arch"
  fi
  local summary_name="docc2context-v${sanitized_version}-${summary_suffix}"
  if [[ "$dry_run" == "1" ]]; then
    summary_name+="-dryrun"
  fi
  local summary_file="$output_dir/${summary_name}.md"
  {
    echo "# docc2context Release Summary"
    echo "- Version: $sanitized_version"
    echo "- Platform: $platform"
    echo "- Architecture: $arch"
    echo "- Release Gates: $([[ "$PACKAGE_RELEASE_SKIP_GATES" == "1" ]] && echo "SKIPPED" || echo "PASSED")"
    echo "- Dry Run: $([[ "$dry_run" == "1" ]] && echo "true" || echo "false")"
    echo "- Generated At: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "- Artifacts:"
    for artifact in "${artifacts[@]}"; do
      local checksum_file="${artifact}.sha256"
      echo "  - $(basename "$artifact")"
      if [[ -f "$checksum_file" ]]; then
        echo "    - Checksum: $(basename "$checksum_file")"
      fi
    done
  } > "$summary_file"
  log_step "Recorded summary: $summary_file"
}

package_macos() {
  local stage_dir="$1"
  local artifact_name="docc2context-v${sanitized_version}-${platform}"
  if [[ -n "$arch" ]]; then
    artifact_name+="-${arch}"
  fi
  if [[ "$dry_run" == "1" ]]; then
    artifact_name+="-dryrun"
  fi
  local artifact_zip="$output_dir/${artifact_name}.zip"
  (cd "$(dirname "$stage_dir")" && zip -rq "$artifact_zip" "$(basename "$stage_dir")")
  log_step "Created artifact: $artifact_zip"
  shasum -a 256 "$artifact_zip" > "$artifact_zip.sha256"
  log_step "Wrote checksum: $artifact_zip.sha256"
  create_summary "$artifact_zip"
}

package_linux() {
  local stage_dir="$1"
  local helper="$SCRIPT_DIR/build_linux_packages.sh"
  if [[ ! -x "$helper" ]]; then
    log_error "Linux packaging helper missing or not executable: $helper"
    exit 1
  fi
  local helper_args=(
    "$helper"
    --version "$sanitized_version"
    --arch "$arch"
    --stage-dir "$stage_dir"
    --binary "$stage_dir/docc2context"
    --output "$output_dir"
  )
  if [[ "$dry_run" == "1" ]]; then
    helper_args+=("--dry-run")
  fi
  local artifacts=()
  while IFS= read -r artifact; do
    if [[ -n "$artifact" ]]; then
      artifacts+=("$artifact")
    fi
  done < <("${helper_args[@]}")
  if [[ "${#artifacts[@]}" -eq 0 ]]; then
    log_error "Linux packaging helper did not produce any artifacts"
    exit 1
  fi
  create_summary "${artifacts[@]}"
}

main() {
  run_release_gates
  local binary_path
  binary_path="$(build_binary)"
  local stage_dir
  stage_dir="$(stage_artifacts "$binary_path")"
  if [[ "$platform" == "linux" ]]; then
    package_linux "$stage_dir"
  else
    package_macos "$stage_dir"
  fi
  log_step "Packaging complete"
}

main
