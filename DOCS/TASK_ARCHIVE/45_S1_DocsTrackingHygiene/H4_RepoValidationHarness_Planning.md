# H4 – Repository Validation Harness (Planning)

**Archived note:** This pre-implementation planning doc is retained for context. The implemented work landed in `DOCS/TASK_ARCHIVE/40_H4_RepositoryValidationHarnessImplementation/`.

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-01
**Owner:** docc2context agent
**Depends On:** H1 repository hosting unblock (provider + credentials), D4-LNX packaging outputs, E4 E2E release simulation

---

## 🎯 Intent

Design a deterministic validation harness for apt/dnf repositories so that once hosting (H1) is enabled, releases can be gated on repository health. The plan emphasizes offline-friendly verification, signature integrity, and install-path smoke runs without touching production credentials yet.

---

## ✅ Selection Rationale
- **Phase integrity:** Builds on completed Phase D packaging and H2/H3 packaging extensions without introducing new runtime features.
- **Dependency awareness:** Work remains preparatory until H1 repository access exists; planning now shortens lead time when credentials arrive.
- **Testing-first:** Defines deterministic checks (hashes, signed metadata, install validation) to encode as XCTests/integration jobs before altering release scripts.
- **Doc sync:** Anticipates README/SECRETS updates for repository consumption and CI secret requirements once implementation begins.

---

## 📐 Scope for START
When START is invoked, implement the following:
1. **Repository probe script** (e.g., `Scripts/validate_package_repos.sh`) that:
   - Downloads `Release`/`InRelease` + `repodata` metadata, verifies signatures against provided GPG keys.
   - Confirms expected package versions + checksums match release artifacts (glibc + musl) for Debian/Ubuntu and Fedora/RHEL families.
   - Performs install smoke runs inside disposable containers (Debian/Ubuntu/Fedora) using published repository endpoints and validates `docc2context --version` output + checksum hashes post-install.
2. **CI wiring:** Optional job added to release workflow to run the probe script when repository secrets/environment variables are present; must remain no-op without credentials.
3. **Test coverage:** Add XCTests or shell-driven tests that simulate repository metadata using fixtures to keep determinism while network-reliant checks stay behind opt-in flags.
4. **Documentation updates:** README installation section gains apt/dnf repository usage instructions; `.github/SECRETS.md` enumerates required secrets (repository URL, GPG key material, auth tokens if private staging is used).

---

## 🔎 Current State Check
- **TODO:** H1 planning listed as in progress; no Ready items exist. This harness planning becomes the next actionable unit while H1 hosting remains blocked.
- **INPROGRESS:** `H1_APTDNFRepositoryHostingPlan.md` captures provider selection + secret inventory; this note focuses on downstream validation once hosting is live.
- **ARCHIVE:** D4-LNX, H2, and H3 archives confirm packaging artifacts and ancillary package-manager integrations already ship, providing inputs for repository validation.

---

## 🚧 Risks & Constraints
- **Credential gating:** End-to-end validation against live repositories cannot proceed until hosting credentials exist; all scripts must default to dry-run/fixture modes.
- **Determinism:** Network access introduces nondeterminism; tests should rely on recorded metadata fixtures or containerized staging mirrors to keep reproducibility.
- **Security:** Signature verification must avoid importing untrusted keys; document key-handling expectations and ensure secrets are masked in CI logs.

---

## 🔜 Next Actions Before START
- Annotate `DOCS/todo.md` to track this planning effort (done).
- Draft fixture plan for repository metadata (sample `Release`/`repomd.xml` + package indexes) to support offline tests.
- Outline CLI and environment contract for the future validation script (inputs: repo URLs, expected version, GPG key path; toggles: `--dry-run`, `--skip-install`).
- Coordinate with H1 owner/maintainer on staging endpoints to mirror when credentials arrive; record decisions in this note.

---

## 📎 References
- [PRD §4.6 Release Packaging & Distribution Requirements](../../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements)
- [D4-LNX Linux Release Packaging Matrix](../25_D4-LNX_LinuxReleasePackagingMatrix/)
- [H2 musl Build Support](../33_H2_muslBuildSupport/)
- [H3 Additional Package Manager Integration](../34_H3_AURPackageIntegration/)
- [H1 APT/DNF Repository Hosting Plan](../../INPROGRESS/H1_APTDNFRepositoryHostingPlan.md)
