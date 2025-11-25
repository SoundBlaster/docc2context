# H1 – APT/DNF Repository Hosting

**Status:** Planning Phase (SELECT_NEXT)
**Date:** 2025-11-25
**Owner:** docc2context agent (deferred to maintainer for execution)
**Depends On:** D4-LNX (✅ complete — Linux release packaging matrix)

---

## 📋 Scope

Establish automated apt/dnf repository hosting infrastructure so Linux users can install `docc2context` via standard package managers (`apt`, `dnf`) without manually downloading GitHub releases. This extends the D4-LNX release packaging work by providing a persistent, auto-updating installation path that integrates into Linux ecosystem conventions.

---

## 🎯 Goals

1. **User convenience** – Linux users can run `apt update && apt install docc2context` or `dnf install docc2context` instead of managing manual downloads.
2. **Automation** – Release workflow automatically publishes `.deb`/`.rpm` packages to the repository on every tagged release.
3. **Sustainability** – Integrate with a third-party repository hosting service (e.g., Cloudsmith, Packagecloud, or GitHub Pages) so maintainers don't need to run their own APT/YUM server.
4. **Discoverability** – Document repository setup in README so users know how to enable the PPA/repo and install.

---

## 📐 Implementation Strategy

### Phase 1: Service Selection & Setup
- **Decision point:** Choose a repository hosting provider:
  - **Cloudsmith** (recommended for open source) — supports apt/dnf, free tier available
  - **Packagecloud** — multiformat support, straightforward API
  - **GitHub Pages + reprepro/createrepo** — self-hosted, zero cost but requires CI/CD lift
  - **Launchpad PPA** — Ubuntu-specific, limited to `.deb`

- **Action:** Evaluate free tiers, API availability, and ease of CLI automation.

### Phase 2: Repository Configuration
- Create APT repository (signed `.deb` packages):
  - Generate or provision GPG key for package signing
  - Configure repository metadata (`Release`, `Packages` files)
  - Set up automatic repository updates on release publishes

- Create DNF repository (signed `.rpm` packages):
  - Configure RPM signing key
  - Set up YUM/DNF repository metadata (`repomd.xml`, `primary.xml`)
  - Document yum/dnf repo URL for end users

### Phase 3: Release Workflow Integration
- **GitHub Actions enhancement:**
  - After D4-LNX artifacts are ready (`.deb` + `.rpm`), publish them to the repository service
  - Add new CI step: `Upload to APT/DNF Repository` (conditional on tag push, after release gates pass)
  - Document required GitHub secrets (e.g., `CLOUDSMITH_API_TOKEN`, repository credentials)

- **Release script updates:**
  - Optionally call repository upload helper directly from `Scripts/package_release.sh` (for manual releases)
  - Add `Scripts/publish_to_repositories.sh` as a modular helper:
    - Accept version, platform, repository credentials
    - Upload packages to configured service
    - Validate upload success

### Phase 4: Documentation & User Guides
- **README updates:**
  - Add "Linux Installation via Package Manager" section covering:
    - How to add the repository (apt sources list + keyring, dnf repo file)
    - Installation command (`apt install docc2context`, `dnf install docc2context`)
    - Upgrade path (`apt upgrade`, `dnf upgrade`)
  - Link to repository service for inspection/statistics

- **Operator documentation:**
  - `.github/REPOSITORY_SETUP.md` — guide for maintainers on provisioning a new repository
  - Document API tokens, signing keys, and CI secret configuration
  - Include troubleshooting (e.g., repository unavailable, signature verification failure)

---

## ✅ Acceptance Criteria

- [ ] **Service provisioned** – Repository hosting account created and configured (API access tested)
- [ ] **GPG keys provisioned** – Package signing keys generated/stored securely
- [ ] **CI/CD integration** – `.github/workflows/release.yml` includes repository upload step with dry-run validation
- [ ] **Manual helper script** – `Scripts/publish_to_repositories.sh` accepts version + credentials and uploads packages (tested locally)
- [ ] **README documented** – Installation via `apt`/`dnf` clearly explained with repository add instructions
- [ ] **End-to-end tested** – Manual release simulation uploads a test package and verifies `apt/dnf` can discover and install it
- [ ] **Secrets configured** – GitHub Actions secrets (repository tokens, signing keys) documented in `.github/SECRETS.md`

---

## 📚 Reference Materials

- **D4-LNX Archive** – `DOCS/TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/` (provides `.deb`/`.rpm` artifacts)
- **Release Workflow** – `.github/workflows/release.yml` (current automation flow)
- **Package Scripts** – `Scripts/package_release.sh`, `Scripts/build_linux_packages.sh`
- **README Installation Section** – Current coverage of tarball + manual install (to be extended)

---

## 🔄 Estimated Effort & Complexity

- **Effort:** 3–4 pts (assumes service selection is quick, integration is moderate, testing is thorough)
- **Risk:** Moderate (API vendor changes, GPG key management, repository availability)
- **Parallelizable:** No — requires sequential service provisioning, CI integration, testing

---

## 🚀 Next Steps (For Execution Phase)

1. **SELECT:** Evaluate and choose a repository hosting provider (Cloudsmith recommended)
2. **PROVISION:** Create account, test API, generate signing keys
3. **INTEGRATE:** Wire repository uploads into `.github/workflows/release.yml` and create helper script
4. **VALIDATE:** Test end-to-end with a dry-run release package
5. **DOCUMENT:** Update README, SECRETS.md, and add operator guide
6. **RELEASE:** Use updated workflow on next real release or trigger a test release to verify

---

## 📝 Deferred to Maintainer

This task is selected for planning but **deferred to project maintainer for execution** due to:
- Requirement for external service account provisioning (vendor selection, credentials)
- One-time setup nature (not immediately critical for feature completeness)
- Operational complexity (repository management, security key handling)

A maintainer should:
1. Review this planning document
2. Select a repository service
3. Provision account and API credentials
4. Coordinate with the next release cycle to wire the integration
5. Validate installation paths work for end users

---

## 🔗 Cross-References

- **Phase D Release Packaging:** `DOCS/TASK_ARCHIVE/24_D4_PackageDistributionRelease/`
- **Blocked Task E3:** `DOCS/INPROGRESS/BLOCKED_E3_SigningNotarization.md` (separate blocker, unrelated to apt/dnf)
- **README Installation:** Section "Linux installation snippets" (to be enhanced)
- **Project Status:** `DOCS/workplan.md`, `DOCS/todo.md`
