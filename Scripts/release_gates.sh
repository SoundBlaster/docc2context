#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_PATH="$REPO_ROOT/Fixtures/manifest.json"
VALIDATOR_SCRIPT="$SCRIPT_DIR/validate_fixtures_manifest.py"
DETERMINISM_COMMAND=${DETERMINISM_COMMAND:-"swift run docc2context --help"}
TMP_ROOT=${DETERMINISM_TMP_DIR:-"$REPO_ROOT/.build/release-gates"}
mkdir -p "$TMP_ROOT"

log_step() {
  printf '\n[%s] %s\n' "$(date -u +%H:%M:%S)" "$1"
}

log_warn() {
  printf '\n[%s][WARN] %s\n' "$(date -u +%H:%M:%S)" "$1"
}

log_error() {
  printf '\n[%s][ERROR] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

run_swift_tests() {
  log_step "Running swift test"
  swift test
}

run_determinism_check() {
  log_step "Running determinism smoke command twice: $DETERMINISM_COMMAND"
  local tmp_dir
  tmp_dir="$(mktemp -d "$TMP_ROOT/determinism.XXXXXX")"
  local first_run="$tmp_dir/run1.txt"
  local second_run="$tmp_dir/run2.txt"

  if ! eval "$DETERMINISM_COMMAND" >"$first_run"; then
    rm -rf "$tmp_dir"
    log_error "Determinism command failed on first run"
    exit 1
  fi
  if ! eval "$DETERMINISM_COMMAND" >"$second_run"; then
    rm -rf "$tmp_dir"
    log_error "Determinism command failed on second run"
    exit 1
  fi

  local first_hash second_hash
  first_hash="$(shasum -a 256 "$first_run" | awk '{print $1}')"
  second_hash="$(shasum -a 256 "$second_run" | awk '{print $1}')"
  rm -rf "$tmp_dir"

  if [[ "$first_hash" != "$second_hash" ]]; then
    log_error "Determinism check failed (hash mismatch: $first_hash vs $second_hash)"
    exit 1
  fi

  log_step "Determinism hash matched: $first_hash"
}

verify_fixture_manifest() {
  log_step "Validating fixture manifest at $MANIFEST_PATH"
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    log_error "Fixture manifest not found at $MANIFEST_PATH"
    exit 1
  fi
  if [[ ! -f "$VALIDATOR_SCRIPT" ]]; then
    log_error "Validator script missing at $VALIDATOR_SCRIPT"
    exit 1
  fi
  python3 "$VALIDATOR_SCRIPT" "$MANIFEST_PATH"
}

main() {
  run_swift_tests
  run_determinism_check
  verify_fixture_manifest
  log_step "Release gate checks completed successfully"
}

main "$@"
