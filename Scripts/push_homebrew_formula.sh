#!/bin/bash
set -euo pipefail

# push_homebrew_formula.sh
# Publishes a Homebrew formula to the tap repository.
# Supports dry-run mode for testing without actual git operations.

# Usage:
#   ./push_homebrew_formula.sh \
#     --formula <path-to-formula.rb> \
#     --tap-repo <git-url> \
#     --version <version> \
#     [--dry-run] \
#     [--branch <branch-name>]

# Default values
DRY_RUN=false
BRANCH="main"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --formula)
            FORMULA_PATH="$2"
            shift 2
            ;;
        --tap-repo)
            TAP_REPO="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            echo "Usage: $0 --formula <path> --tap-repo <url> --version <version> [--dry-run] [--branch <branch>]" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "${FORMULA_PATH:-}" ]]; then
    echo "Error: --formula is required" >&2
    exit 1
fi

if [[ -z "${TAP_REPO:-}" ]]; then
    echo "Error: --tap-repo is required" >&2
    exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
    echo "Error: --version is required" >&2
    exit 1
fi

# Validate formula file exists
if [[ ! -f "$FORMULA_PATH" ]]; then
    echo "Error: Formula file not found: $FORMULA_PATH" >&2
    exit 1
fi

# Sanitize version (remove leading 'v' if present)
CLEAN_VERSION="${VERSION#v}"

# Prepare commit message
COMMIT_MESSAGE="chore(homebrew): update docc2context formula to ${VERSION}

This commit updates the Homebrew formula to version ${VERSION}.

Automated by push_homebrew_formula.sh"

# Function to execute or print command based on dry-run mode
execute_or_print() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] $*"
    else
        echo "Executing: $*"
        "$@"
    fi
}

# Main execution
if [[ "$DRY_RUN" == "true" ]]; then
    echo "========================================="
    echo "DRY RUN MODE - No actual changes will be made"
    echo "========================================="
fi

# Create temporary directory for tap repository
TAP_WORK_DIR=$(mktemp -d -t homebrew-tap-XXXXXX)

if [[ "$DRY_RUN" == "false" ]]; then
    trap "rm -rf '$TAP_WORK_DIR'" EXIT
fi

echo "Formula path: $FORMULA_PATH"
echo "Tap repository: $TAP_REPO"
echo "Version: $VERSION (clean: $CLEAN_VERSION)"
echo "Target branch: $BRANCH"
echo "Work directory: $TAP_WORK_DIR"
echo

# Clone tap repository
echo "Step 1: Clone tap repository"
execute_or_print git clone --depth 1 --branch "$BRANCH" "$TAP_REPO" "$TAP_WORK_DIR"
echo

# Copy formula to tap repository
FORMULA_TARGET="$TAP_WORK_DIR/Formula/docc2context.rb"
echo "Step 2: Copy formula to $FORMULA_TARGET"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] mkdir -p $TAP_WORK_DIR/Formula"
    echo "[DRY RUN] cp $FORMULA_PATH $FORMULA_TARGET"
else
    mkdir -p "$TAP_WORK_DIR/Formula"
    cp "$FORMULA_PATH" "$FORMULA_TARGET"
fi
echo

# Configure git (if not in dry-run mode)
if [[ "$DRY_RUN" == "false" ]]; then
    cd "$TAP_WORK_DIR"

    # Use GitHub Actions bot identity if no git config exists
    if ! git config user.email >/dev/null 2>&1; then
        git config user.email "github-actions[bot]@users.noreply.github.com"
    fi
    if ! git config user.name >/dev/null 2>&1; then
        git config user.name "github-actions[bot]"
    fi
fi

# Stage changes
echo "Step 3: Stage formula changes"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] cd $TAP_WORK_DIR"
    echo "[DRY RUN] git add Formula/docc2context.rb"
else
    cd "$TAP_WORK_DIR"
    git add Formula/docc2context.rb
fi
echo

# Commit changes
echo "Step 4: Commit changes"
echo "Commit message:"
echo "---"
echo "$COMMIT_MESSAGE"
echo "---"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN] git commit -m \"$COMMIT_MESSAGE\""
else
    git commit -m "$COMMIT_MESSAGE"
fi
echo

# Push to tap repository
echo "Step 5: Push to tap repository"
execute_or_print git push origin "$BRANCH"
echo

if [[ "$DRY_RUN" == "true" ]]; then
    echo "========================================="
    echo "DRY RUN COMPLETE - No changes were made"
    echo "========================================="
    echo
    echo "To execute for real, remove the --dry-run flag"
else
    echo "========================================="
    echo "SUCCESS: Formula published to tap"
    echo "========================================="
    echo
    echo "Users can now install with:"
    echo "  brew tap $(basename $(dirname $TAP_REPO))/$(basename $TAP_REPO .git | sed 's/^homebrew-//')"
    echo "  brew install docc2context"
fi

exit 0
