#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_PATH="$REPO_ROOT/Fixtures/manifest.json"
VALIDATOR_SCRIPT="$SCRIPT_DIR/validate_fixtures_manifest.py"
DETERMINISM_COMMAND=${DETERMINISM_COMMAND:-"swift run docc2context --help"}
TMP_ROOT=${DETERMINISM_TMP_DIR:-"$REPO_ROOT/.build/release-gates"}
COVERAGE_THRESHOLD=${COVERAGE_THRESHOLD:-"90"}
REPOSITORY_VALIDATION_FLAGS_ARRAY=()
if [[ -n "${REPOSITORY_VALIDATION_FLAGS:-}" ]]; then
  read -r -a REPOSITORY_VALIDATION_FLAGS_ARRAY <<<"${REPOSITORY_VALIDATION_FLAGS}"
fi
mkdir -p "$TMP_ROOT"
cd "$REPO_ROOT"

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
  log_step "Running swift test with coverage"
  swift test --enable-code-coverage
}

run_coverage_gate() {
  log_step "Enforcing coverage threshold (${COVERAGE_THRESHOLD}%)"
  python3 "$SCRIPT_DIR/enforce_coverage.py" --threshold "$COVERAGE_THRESHOLD"
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

run_full_determinism_check() {
  log_step "Running full output determinism check on TutorialCatalog fixture"

  local output_dir1 output_dir2
  output_dir1="$(mktemp -d "$TMP_ROOT/determinism_output1.XXXXXX")"
  output_dir2="$(mktemp -d "$TMP_ROOT/determinism_output2.XXXXXX")"

  log_step "Output directories: $output_dir1 and $output_dir2"

  # Get fixture path (located in repo root Fixtures directory)
  local fixture_path="$REPO_ROOT/Fixtures/TutorialCatalog.doccarchive"

  if [[ ! -d "$fixture_path" ]]; then
    log_warn "Tutorial fixture not found at $fixture_path, skipping full determinism check"
    rm -rf "$output_dir1" "$output_dir2"
    return 0
  fi

  log_step "Found fixture at $fixture_path"

  # First conversion run
  log_step "Running first markdown conversion..."
  local first_run_log="$TMP_ROOT/first_run.log"
  if ! swift run docc2context "$fixture_path" --output "$output_dir1" --format markdown --force >"$first_run_log" 2>&1; then
    log_error "First determinism conversion run failed. Output:"
    cat "$first_run_log" >&2
    rm -rf "$output_dir1" "$output_dir2" "$first_run_log"
    exit 1
  fi
  rm -f "$first_run_log"

  # Second conversion run
  log_step "Running second markdown conversion..."
  local second_run_log="$TMP_ROOT/second_run.log"
  if ! swift run docc2context "$fixture_path" --output "$output_dir2" --format markdown --force >"$second_run_log" 2>&1; then
    log_error "Second determinism conversion run failed. Output:"
    cat "$second_run_log" >&2
    rm -rf "$output_dir1" "$output_dir2" "$second_run_log"
    exit 1
  fi
  rm -f "$second_run_log"

  # Compare outputs using find and checksums
  log_step "Comparing output directory checksums..."
  local found_diff=0

  # Get sorted list of relative paths from each output directory
  # Use relative paths to avoid comparing different temp directory paths
  local files1 files2
  files1=$(cd "$output_dir1" && find . -type f 2>/dev/null | sort)
  files2=$(cd "$output_dir2" && find . -type f 2>/dev/null | sort)

  log_step "First run generated $(echo "$files1" | wc -l) files"
  log_step "Second run generated $(echo "$files2" | wc -l) files"

  # Check if file lists are identical (same number of files)
  local count1=$(echo "$files1" | wc -l)
  local count2=$(echo "$files2" | wc -l)
  if [[ "$count1" != "$count2" ]]; then
    log_error "Different number of files: $count1 vs $count2"
    found_diff=1
  fi

  # Compare file checksums
  if [[ $found_diff -eq 0 && -n "$files1" ]]; then
    while IFS= read -r rel_path; do
      local file1="$output_dir1/$rel_path"
      local file2="$output_dir2/$rel_path"

      if [[ ! -f "$file2" ]]; then
        log_error "File missing in second run: $rel_path"
        found_diff=1
        break
      fi

      local hash1 hash2
      hash1=$(shasum -a 256 "$file1" | awk '{print $1}')
      hash2=$(shasum -a 256 "$file2" | awk '{print $1}')

      if [[ "$hash1" != "$hash2" ]]; then
        log_error "Content differs for file: $rel_path"
        found_diff=1
        break
      fi
    done <<< "$files1"
  elif [[ $found_diff -eq 0 && -z "$files1" ]]; then
    log_error "No files found in output directories"
    found_diff=1
  fi

  rm -rf "$output_dir1" "$output_dir2"

  if [[ $found_diff -ne 0 ]]; then
    log_error "Full output determinism check failed"
    exit 1
  fi

  log_step "Full output determinism check passed"
}

run_repository_validation() {
  log_step "Validating repository metadata fixtures"
  swift run repository-validation --fixtures-path "$REPO_ROOT/Fixtures/RepositoryMetadata" "${REPOSITORY_VALIDATION_FLAGS_ARRAY[@]}"
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
  run_coverage_gate
  run_determinism_check
  run_full_determinism_check
  verify_fixture_manifest
  run_repository_validation
  log_step "Release gate checks completed successfully"
}

main "$@"
