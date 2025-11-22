#!/usr/bin/env bash
# profile_memory.sh — Measure peak memory usage for docc2context conversions
#
# Purpose:
#   Baseline profiling helper for F1 Incremental Conversion task.
#   Measures peak RSS (Resident Set Size) and wall-clock time for
#   docc2context runs on various fixture bundles.
#
# Usage:
#   ./Scripts/profile_memory.sh [output_dir]
#
# Dependencies:
#   - /usr/bin/time (GNU time with -v flag for detailed stats)
#   - swift build (Swift toolchain)
#   - docc2context executable
#
# Output:
#   - Creates profiling report with memory/time metrics
#   - Exits 0 on success, non-zero on failure

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FIXTURES_DIR="${PROJECT_ROOT}/Fixtures"
OUTPUT_DIR="${1:-${PROJECT_ROOT}/dist/profiling}"
REPORT_FILE="${OUTPUT_DIR}/profile_report.txt"
TIME_BIN="/usr/bin/time"

# Ensure Swift is in PATH
if ! command -v swift &> /dev/null; then
    if [ -d "/usr/local/swift/usr/bin" ]; then
        export PATH="/usr/local/swift/usr/bin:$PATH"
    else
        echo "[ERROR] Swift not found in PATH" >&2
        exit 1
    fi
fi

# Build docc2context in release mode for accurate profiling
echo "[INFO] Building docc2context in release mode..."
cd "${PROJECT_ROOT}"
swift build -c release

EXECUTABLE="${PROJECT_ROOT}/.build/release/docc2context"
if [ ! -x "${EXECUTABLE}" ]; then
    echo "[ERROR] docc2context executable not found at ${EXECUTABLE}" >&2
    exit 1
fi

# Prepare output directory
mkdir -p "${OUTPUT_DIR}"
rm -f "${REPORT_FILE}"

# Profile header
cat > "${REPORT_FILE}" <<EOF
docc2context Memory Profiling Report
Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Executable: ${EXECUTABLE}
Swift Version: $(swift --version | head -n1)
System: $(uname -a)

==================================================
EOF

# Profile each fixture
profile_fixture() {
    local fixture_path="$1"
    local fixture_name="$(basename "${fixture_path}" .doccarchive)"
    local temp_output="${OUTPUT_DIR}/${fixture_name}_output"
    local time_output="${OUTPUT_DIR}/${fixture_name}_time.txt"

    echo "[INFO] Profiling ${fixture_name}..."

    # Clean output directory
    rm -rf "${temp_output}"
    mkdir -p "${temp_output}"

    # Run with time profiling
    # Use pipefail to catch errors in the pipeline
    set +e  # Temporarily disable exit on error
    "${TIME_BIN}" -v "${EXECUTABLE}" "${fixture_path}" \
        --output "${temp_output}" --force \
        > "${time_output}.stdout" 2>&1
    local exit_code=$?
    set -e  # Re-enable exit on error

    # Merge time output (stderr) with stdout for parsing
    cat "${time_output}.stdout" > "${time_output}"

    if [ ${exit_code} -eq 0 ]; then

        # Extract metrics from time output
        local max_rss=$(grep "Maximum resident set size" "${time_output}" | awk '{print $6}')
        local wall_time=$(grep "Elapsed (wall clock)" "${time_output}" | awk '{print $8}')
        local user_time=$(grep "User time" "${time_output}" | awk '{print $4}')
        local sys_time=$(grep "System time" "${time_output}" | awk '{print $4}')

        # Convert RSS from KB to MB if available
        local max_rss_mb="N/A"
        if [ -n "${max_rss}" ] && [ "${max_rss}" != "0" ]; then
            max_rss_mb=$(awk "BEGIN {printf \"%.2f\", ${max_rss}/1024}")
        fi

        # Count output files
        local output_files=$(find "${temp_output}" -type f | wc -l)

        # Append to report
        cat >> "${REPORT_FILE}" <<EOF

Fixture: ${fixture_name}
----------------------------------------
Input Path: ${fixture_path}
Peak RSS: ${max_rss_mb} MB (${max_rss} KB)
Wall Clock Time: ${wall_time}
User Time: ${user_time}s
System Time: ${sys_time}s
Output Files Generated: ${output_files}

EOF
    else
        echo "[ERROR] Failed to profile ${fixture_name}" >&2
        cat >> "${REPORT_FILE}" <<EOF

Fixture: ${fixture_name}
----------------------------------------
Status: FAILED
Error: docc2context conversion failed

EOF
    fi

    # Cleanup temporary files
    rm -rf "${temp_output}"
    rm -f "${time_output}"
}

# Profile all fixtures
echo "[INFO] Starting profiling run..."
for fixture in "${FIXTURES_DIR}"/*.doccarchive; do
    if [ -d "${fixture}" ]; then
        profile_fixture "${fixture}"
    fi
done

# Add summary footer
cat >> "${REPORT_FILE}" <<EOF
==================================================
End of profiling report
EOF

echo "[INFO] Profiling complete"
echo "[INFO] Report saved to: ${REPORT_FILE}"
cat "${REPORT_FILE}"
