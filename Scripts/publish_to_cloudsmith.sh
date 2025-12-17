#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
Usage: $(basename "$0") --owner <cloudsmith-owner> --repository <repo> --version <semver> --artifact-dir <dir> [options]

Required:
  --owner           Cloudsmith organization/owner slug (or set CLOUDSMITH_OWNER)
  --repository      Cloudsmith repository slug (or set CLOUDSMITH_REPOSITORY)
  --version         Release version (accepts optional leading 'v')
  --artifact-dir    Directory containing .deb and .rpm artifacts (searches recursively)

Options:
  --skip-deb          Skip publishing Debian packages (allow rpm-only uploads)
  --skip-rpm          Skip publishing RPM packages (allow deb-only uploads)
  --apt-distribution  Debian distribution slug (default: CLOUDSMITH_APT_DISTRIBUTION or 'ubuntu')
  --apt-release       Debian release codename (default: CLOUDSMITH_APT_RELEASE or 'jammy')
  --apt-component     Debian component name (default: CLOUDSMITH_APT_COMPONENT or 'main')
  --rpm-distribution  RPM distribution slug (default: CLOUDSMITH_RPM_DISTRIBUTION or 'any-distro')
  --rpm-release       RPM release version (default: CLOUDSMITH_RPM_RELEASE or 'any-version')
  --dry-run           Print intended actions without invoking the Cloudsmith API
  -h, --help          Show this message
USAGE
}

owner="${CLOUDSMITH_OWNER:-""}"
repository="${CLOUDSMITH_REPOSITORY:-""}"
version=""
artifact_dir=""
apt_distribution="${CLOUDSMITH_APT_DISTRIBUTION:-"ubuntu"}"
apt_release="${CLOUDSMITH_APT_RELEASE:-"jammy"}"
apt_component="${CLOUDSMITH_APT_COMPONENT:-"main"}"
rpm_distribution="${CLOUDSMITH_RPM_DISTRIBUTION:-"any-distro"}"
rpm_release="${CLOUDSMITH_RPM_RELEASE:-"any-version"}"
dry_run="0"
skip_deb="0"
skip_rpm="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--owner requires a value"
        usage
        exit 1
      fi
      owner="$2"
      shift 2
      ;;
    --repository)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--repository requires a value"
        usage
        exit 1
      fi
      repository="$2"
      shift 2
      ;;
    --version)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--version requires a value"
        usage
        exit 1
      fi
      version="$2"
      shift 2
      ;;
    --artifact-dir)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--artifact-dir requires a value"
        usage
        exit 1
      fi
      artifact_dir="$2"
      shift 2
      ;;
    --apt-distribution)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--apt-distribution requires a value"
        usage
        exit 1
      fi
      apt_distribution="$2"
      shift 2
      ;;
    --apt-release)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--apt-release requires a value"
        usage
        exit 1
      fi
      apt_release="$2"
      shift 2
      ;;
    --apt-component)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--apt-component requires a value"
        usage
        exit 1
      fi
      apt_component="$2"
      shift 2
      ;;
    --rpm-distribution)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--rpm-distribution requires a value"
        usage
        exit 1
      fi
      rpm_distribution="$2"
      shift 2
      ;;
    --rpm-release)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log_error "--rpm-release requires a value"
        usage
        exit 1
      fi
      rpm_release="$2"
      shift 2
      ;;
    --dry-run)
      dry_run="1"
      shift 1
      ;;
    --skip-deb)
      skip_deb="1"
      shift 1
      ;;
    --skip-rpm)
      skip_rpm="1"
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

if [[ -z "$owner" || -z "$repository" || -z "$version" || -z "$artifact_dir" ]]; then
  log_error "Missing required arguments. --owner, --repository, --version, and --artifact-dir are required."
  usage
  exit 1
fi

sanitized_version="${version#v}"
if [[ -z "$sanitized_version" || ! "$sanitized_version" =~ ^[0-9]+(\.[0-9A-Za-z-]+)*$ ]]; then
  log_error "Version '$version' is not a valid semantic version"
  exit 1
fi

if [[ ! -d "$artifact_dir" ]]; then
  log_error "Artifact directory does not exist: $artifact_dir"
  exit 1
fi

if [[ "$skip_deb" == "1" && "$skip_rpm" == "1" ]]; then
  log_error "Both --skip-deb and --skip-rpm were set; nothing to upload."
  exit 1
fi

deb_files=()
skipped_deb_files=()
if [[ "$skip_deb" == "0" ]]; then
  while IFS= read -r deb_path; do
    base="$(basename "$deb_path")"
    if [[ "$base" == *-musl.deb ]]; then
      skipped_deb_files+=("$deb_path")
      continue
    fi
    deb_files+=("$deb_path")
  done < <(find "$artifact_dir" -type f -name "*.deb" | sort)
fi

rpm_files=()
skipped_rpm_files=()
if [[ "$skip_rpm" == "0" ]]; then
  while IFS= read -r rpm_path; do
    base="$(basename "$rpm_path")"
    if [[ "$base" == *-musl.rpm ]]; then
      skipped_rpm_files+=("$rpm_path")
      continue
    fi
    rpm_files+=("$rpm_path")
  done < <(find "$artifact_dir" -type f -name "*.rpm" | sort)
fi

if [[ ${#skipped_deb_files[@]} -gt 0 ]]; then
  log_warn "Skipping ${#skipped_deb_files[@]} variant package(s) (musl) for repository publishing:"
  for artifact in "${skipped_deb_files[@]}"; do
    printf '  - %s\n' "$artifact" >&2
  done
  log_warn "Publish musl variants via tarball releases (or add an explicit opt-in flag once package naming/repo layout is decided)."
fi

if [[ ${#skipped_rpm_files[@]} -gt 0 ]]; then
  log_warn "Skipping ${#skipped_rpm_files[@]} variant package(s) (musl) for repository publishing:"
  for artifact in "${skipped_rpm_files[@]}"; do
    printf '  - %s\n' "$artifact" >&2
  done
  log_warn "Publish musl variants via tarball releases (or add an explicit opt-in flag once package naming/repo layout is decided)."
fi

missing_artifacts=0
if [[ "$skip_deb" == "0" && ${#deb_files[@]} -eq 0 ]]; then
  log_error "No .deb packages found under $artifact_dir"
  missing_artifacts=1
fi
if [[ "$skip_rpm" == "0" && ${#rpm_files[@]} -eq 0 ]]; then
  log_error "No .rpm packages found under $artifact_dir"
  missing_artifacts=1
fi
if [[ "$missing_artifacts" -ne 0 ]]; then
  exit 1
fi

print_plan() {
  log_step "DRY RUN: would upload ${#deb_files[@]} Debian package(s) and ${#rpm_files[@]} RPM package(s) to $owner/$repository"
  printf '  APT target: %s/%s (component: %s)\n' "$apt_distribution" "$apt_release" "$apt_component" >&2
  printf '  RPM target: %s/%s\n' "$rpm_distribution" "$rpm_release" >&2
  printf '  Version: %s\n' "$sanitized_version" >&2

  if [[ ${#deb_files[@]} -gt 0 ]]; then
    for deb in "${deb_files[@]}"; do
      printf '  cloudsmith push deb %s/%s "%s" --api-key $CLOUDSMITH_API_KEY --distribution "%s" --release "%s" --component "%s" --version "%s" --republish\n' \
        "$owner" "$repository" "$deb" "$apt_distribution" "$apt_release" "$apt_component" "$sanitized_version" >&2
    done
  fi

  if [[ ${#rpm_files[@]} -gt 0 ]]; then
    for rpm in "${rpm_files[@]}"; do
      printf '  cloudsmith push rpm %s/%s "%s" --api-key $CLOUDSMITH_API_KEY --distribution "%s" --release "%s" --version "%s" --republish\n' \
        "$owner" "$repository" "$rpm" "$rpm_distribution" "$rpm_release" "$sanitized_version" >&2
    done
  fi
}

if [[ "$dry_run" == "1" ]]; then
  print_plan
  exit 0
fi

if [[ -z "${CLOUDSMITH_API_KEY:-}" ]]; then
  log_error "CLOUDSMITH_API_KEY is required for uploads"
  exit 1
fi

if ! command -v cloudsmith >/dev/null 2>&1; then
  log_error "cloudsmith CLI not found. Install with: python3 -m pip install --upgrade cloudsmith-cli"
  exit 1
fi

log_step "Uploading Debian packages to Cloudsmith"
if [[ ${#deb_files[@]} -gt 0 ]]; then
  for deb in "${deb_files[@]}"; do
    cloudsmith push deb "$owner/$repository" "$deb" \
      --api-key "$CLOUDSMITH_API_KEY" \
      --distribution "$apt_distribution" \
      --release "$apt_release" \
      --component "$apt_component" \
      --version "$sanitized_version" \
      --republish
    log_step "Uploaded $(basename "$deb")"
  done
fi

log_step "Uploading RPM packages to Cloudsmith"
if [[ ${#rpm_files[@]} -gt 0 ]]; then
  for rpm in "${rpm_files[@]}"; do
    cloudsmith push rpm "$owner/$repository" "$rpm" \
      --api-key "$CLOUDSMITH_API_KEY" \
      --distribution "$rpm_distribution" \
      --release "$rpm_release" \
      --version "$sanitized_version" \
      --republish
    log_step "Uploaded $(basename "$rpm")"
  done
fi

log_step "Cloudsmith uploads complete"
