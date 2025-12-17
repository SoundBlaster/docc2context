# H5 – Repository Metadata Fixtures & Offline Harness (Planning)

**Archived note:** This pre-implementation planning doc is retained for context. The implemented work landed in `DOCS/TASK_ARCHIVE/39_H5_RepositoryMetadataFixturesImplementation/`.

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-10
**Owner:** docc2context agent
**Depends On:** H1 repository hosting unblock, H4 validation harness design, D4-LNX packaging outputs

---

## 🎯 Intent

Prepare deterministic apt/dnf repository metadata fixtures and an offline-friendly validation harness outline so H4 can be implemented without waiting on live hosting. The goal is to mirror Cloudsmith/Packagecloud layouts for Debian/Ubuntu and Fedora/RHEL families, enabling reproducible tests that verify repository indexes, signatures, and package availability using existing release artifacts.

---

## ✅ Selection Rationale
- **Phase integrity:** Extends Phase D packaging work with validation scaffolding while deferring any runtime code changes until START.
- **Dependency awareness:** H1 hosting remains blocked; building fixtures now reduces lead time once credentials arrive and unblocks portions of H4.
- **Testing-first:** Establishes fixture-driven checks and deterministic container smoke tests to codify acceptance criteria before wiring scripts.
- **Doc sync:** Identifies README/SECRETS updates required for repository consumption and CI secret handling once hosting is live.

---

## 📐 Scope for START
When START is invoked, the task should:
1. **Create repository metadata fixtures** mirroring `Release`/`InRelease`, `Packages`, and `repodata/repomd.xml`/`primary.xml` structures for apt and dnf, seeded with hashes matching existing `.deb`/`.rpm` artifacts.
2. **Implement an offline validation harness** (e.g., `Scripts/mock_repo_validator.sh` + XCTests) that reads the fixtures, verifies signatures against test keys, and asserts package version/checksum presence without network access.
3. **Define containerized smoke-test templates** (Debian/Ubuntu/Fedora) gated behind environment flags so CI can later run install checks against staging repositories using the same contract.
4. **Document configuration points** in README and `.github/SECRETS.md` (expected repo URLs, GPG key paths, toggle flags) to keep operator guidance aligned with H1/H4 outcomes.

---

## 🔎 Current State Check
- **TODO:** No Ready items; H1 hosting and H4 validation harness are marked In Progress (planning). This H5 note adds offline fixture preparation to unblock future execution.
- **INPROGRESS:** Builds on `H1_APTDNFRepositoryHostingPlan.md` (provider/secret planning) and `H4_RepoValidationHarness.md` (validation flow design).
- **ARCHIVE:** D4-LNX, H2, and H3 archives confirm packaging formats and distribution scripts that the fixtures must mirror.

---

## 🚧 Risks & Constraints
- **Fidelity of fixtures:** Metadata must accurately reflect provider-specific layout conventions; mismatches could produce false confidence.
- **Key handling:** Test signing keys need strict isolation from production credentials to avoid leakage or misconfiguration.
- **Determinism:** Generated fixtures must be stable across regenerations; include hashing guidance to prevent drift.

---

## 🔜 Next Actions Before START
- Update `DOCS/todo.md` to track H5 as active planning work.
- Catalogue required fixture files and signing key placeholders; outline generation steps and hashing expectations in this note.
- Coordinate with H1/H4 planning to ensure fixture schema matches targeted hosting provider conventions.
- Identify container images and invocation flags for future smoke tests, noting which steps remain disabled until credentials exist.

---

## 📎 References
- [PRD §4.6 Release Packaging & Distribution Requirements](../../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements)
- [D4-LNX Linux Release Packaging Matrix](../25_D4-LNX_LinuxReleasePackagingMatrix/)
- [H1 APT/DNF Repository Hosting Plan](../../INPROGRESS/H1_APTDNFRepositoryHostingPlan.md)
- [H4 Repository Validation Harness](H4_RepoValidationHarness_Planning.md)
