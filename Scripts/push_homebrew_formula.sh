#!/usr/bin/env bash
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

log_step() {
  printf '\n[%s] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

log_error() {
  printf '\n[%s][ERROR] %s\n' "$(date -u +%H:%M:%S)" "$1" >&2
}

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
            log_error "Unknown argument: $1"
            log_error "Usage: $0 --formula <path> --tap-repo <url> --version <version> [--dry-run] [--branch <branch>]"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "${FORMULA_PATH:-}" ]]; then
    log_error "--formula is required"
    exit 1
fi

if [[ -z "${TAP_REPO:-}" ]]; then
    log_error "--tap-repo is required"
    exit 1
fi

if [[ -z "${VERSION:-}" ]]; then
    log_error "--version is required"
    exit 1
fi

# Validate formula file exists
if [[ ! -f "$FORMULA_PATH" ]]; then
    log_error "Formula file not found: $FORMULA_PATH"
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
        log_step "[DRY RUN] $*"
    else
        log_step "Executing: $*"
        "$@"
    fi
}

# Main execution
if [[ "$DRY_RUN" == "true" ]]; then
    log_step "========================================="
    log_step "DRY RUN MODE - No actual changes will be made"
    log_step "========================================="
fi

log_step "Formula path: $FORMULA_PATH"
log_step "Tap repository: $TAP_REPO"
log_step "Version: $VERSION (clean: $CLEAN_VERSION)"
log_step "Target branch: $BRANCH"

# Create temporary directory for tap repository
TAP_WORK_DIR=$(mktemp -d -t homebrew-tap-XXXXXX)

if [[ "$DRY_RUN" == "false" ]]; then
    trap "rm -rf '$TAP_WORK_DIR'" EXIT
else
    # Cleanup temp directories in dry-run mode as well
    trap "rm -rf '$TAP_WORK_DIR'" EXIT
fi

log_step "Work directory: $TAP_WORK_DIR"

# Clone tap repository
log_step "Step 1: Clone tap repository"
execute_or_print git clone --depth 1 --branch "$BRANCH" "$TAP_REPO" "$TAP_WORK_DIR"

# Copy formula to tap repository
FORMULA_TARGET="$TAP_WORK_DIR/Formula/docc2context.rb"
log_step "Step 2: Copy formula to $FORMULA_TARGET"

if [[ "$DRY_RUN" == "true" ]]; then
    log_step "[DRY RUN] mkdir -p $TAP_WORK_DIR/Formula"
    log_step "[DRY RUN] cp $FORMULA_PATH $FORMULA_TARGET"
else
    mkdir -p "$TAP_WORK_DIR/Formula"
    cp "$FORMULA_PATH" "$FORMULA_TARGET"
fi

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
log_step "Step 3: Stage formula changes"
if [[ "$DRY_RUN" == "true" ]]; then
    log_step "[DRY RUN] cd $TAP_WORK_DIR"
    log_step "[DRY RUN] git add Formula/docc2context.rb"
else
    cd "$TAP_WORK_DIR"
    git add Formula/docc2context.rb
fi

# Commit changes
log_step "Step 4: Commit changes"
log_step "Commit message:"
log_step "---"
log_step "$COMMIT_MESSAGE"
log_step "---"

if [[ "$DRY_RUN" == "true" ]]; then
    log_step "[DRY RUN] git commit -m \"$COMMIT_MESSAGE\""
else
    git commit -m "$COMMIT_MESSAGE"
fi

# Push to tap repository
log_step "Step 5: Push to tap repository"
execute_or_print git push origin "$BRANCH"

if [[ "$DRY_RUN" == "true" ]]; then
    log_step "========================================="
    log_step "DRY RUN COMPLETE - No changes were made"
    log_step "========================================="
    log_step ""
    log_step "To execute for real, remove the --dry-run flag"
else
    log_step "========================================="
    log_step "SUCCESS: Formula published to tap"
    log_step "========================================="
    log_step ""
    # Extract tap name for installation instructions
    TAP_ORG="$(basename "$(dirname "$TAP_REPO")")"
    TAP_NAME="$(basename "$TAP_REPO" .git | sed 's/^homebrew-//')"
    log_step "Users can now install with:"
    log_step "  brew tap ${TAP_ORG}/${TAP_NAME}"
    log_step "  brew install docc2context"
fi

exit 0
