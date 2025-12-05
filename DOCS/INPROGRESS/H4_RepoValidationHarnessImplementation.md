# H4 – Repository Validation Harness Implementation (SELECT_NEXT Planning)

**Status:** Implemented via START (execution complete)
**Date:** 2025-12-22
**Owner:** docc2context agent
**Depends On:** H1 repository hosting unblock (service + credentials), H5 metadata fixtures/offline harness (implementation now landed), D4-LNX packaging artifacts, E4 release simulation coverage

---

## 🎯 Intent

Select the implementation work that will operationalize the repository validation harness once hosting (H1) and fixtures (H5) are ready. The goal is to enforce deterministic repository health checks (metadata signatures, package availability, install smoke tests) before any apt/dnf uploads go live, with opt-in CI wiring that stays offline-friendly by default.

---

## ✅ Selection Rationale
- **Phase alignment:** Builds directly on completed packaging (D4-LNX) and musl support (H2) while extending prior H4/H5 planning into executable code.
- **Dependency awareness:** Keeps validation logic feature-flagged until hosting credentials exist and leans on H5 fixtures to cover offline flows, minimizing risk to current release workflows.
- **Testing-first:** Commits to landing fixture-backed XCTests plus scripted probes before enabling live network checks, preserving determinism.
- **Doc sync:** Creates a path to update README/SECRETS once the harness is integrated, keeping operators informed about repository gates.

---

## 🔎 Readiness Snapshot (2025-12-03)
- **TODO:** Updated to mark this implementation as the next START candidate with offline focus (see `DOCS/todo.md`).
- **Dependencies:** H5 repository metadata fixtures implementation is archived, providing deterministic apt/dnf metadata and signing keys for offline validation. H1 hosting remains blocked, so live probes stay feature-flagged.
- **Open questions:** Need provider-aligned endpoint naming (Cloudsmith vs. Packagecloud) and container image choices for smoke testing once credentials exist.

---

## 📐 Scope for START
When START runs for this task, implement and validate:
1. **Validation script + library seams**
   - Add a script (e.g., `Scripts/validate_package_repos.sh`) that consumes apt/dnf endpoints, expected version/build IDs, and GPG key paths.
   - Support modes: fixture-only validation (default), live repository probe (flag-gated), and containerized install smoke tests (opt-in).
2. **XCTest coverage**
   - Add deterministic tests that feed the script/library with H5 fixtures, asserting signature verification, package presence, and checksum alignment to release artifacts (glibc + musl).
   - Include negative cases for missing metadata, mismatched versions, or invalid signatures.
3. **CI integration hooks**
   - Wire an optional job into the release workflow that executes fixture-mode by default and live-mode only when repository credentials + staging URLs are provided.
   - Reuse existing release gate entry points so validation stays opt-in until H1 hosting is live.
4. **Documentation updates**
   - Extend README installation docs with repository validation expectations and flags.
   - Update `.github/SECRETS.md` with required secrets/environment variables for live probes (repo URLs, GPG keys, staging tokens) and guidance on masking outputs.

---

## ✅ START Implementation Summary
- Added a Swift `RepositoryValidationHarness` with apt/dnf expectations, checksum verification, and detailed issue reporting for Release/InRelease, Packages, `repomd.xml`, and `primary.xml` inputs.
- Introduced a `repository-validation` executable (ArgumentParser-based) to run the harness in fixture mode or with overridden expectations for staged repositories; defaults to `Fixtures/RepositoryMetadata`.
- Expanded release gates to invoke `repository-validation` so fixture metadata integrity is enforced alongside determinism and coverage checks.
- Documented usage in `README.md` and captured future live-probe secret placeholders in `.github/SECRETS.md`.
- New XCTest coverage detects tampered Packages hashes and expectation drift while keeping the happy-path fixture validation green.

---

## 🧪 Success Metrics
- Fixture-driven tests pass deterministically across platforms (no network access required).
- Live-mode probes no-op gracefully when credentials are absent; CI remains green in offline environments.
- Release workflow can gate uploads on validation success without modifying packaging outputs.
- README/SECRETS entries explicitly list configuration knobs and security expectations.

---

## 🚧 Risks & Mitigations
- **Credential leakage:** Ensure scripts read keys from files/paths supplied via env vars and never echo sensitive material; add logging redaction guards.
- **Nondeterminism:** Default to fixture mode and containerized smoke tests that run only when explicitly enabled; record hash expectations for fixtures.
- **Provider variance:** Abstract repository layout assumptions so Cloudsmith/Packagecloud differences are parameterized via inputs or fixture directories.

---

## 🔜 Next Steps (before START)
- Cross-link to the completed H5 fixture implementation and capture which fixture directories + signing keys should be exercised first.
- Inventory release workflow touchpoints that will consume the validation script and note any required feature flags or environment toggles to keep CI deterministic.
- Coordinate with H1 hosting plan to align repository endpoints, distribution names, and signing key handling so fixture expectations mirror the eventual provider.
- Draft README/SECRETS sections offline so text changes can ship alongside code/test updates during START (documenting fixture-mode vs. live-mode usage).
- Identify container images for Debian/Ubuntu/Fedora smoke runs and decide which should be enabled in offline-only mode using local fixtures.

---

## 📎 References
- [PRD §4.6 Release Packaging & Distribution Requirements](../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements)
- [Workplan – Phase E/H follow-ups](../workplan.md)
- [H1 APT/DNF Repository Hosting Plan](H1_APTDNFRepositoryHostingPlan.md)
- [H4 Repository Validation Harness (Planning)](H4_RepoValidationHarness.md)
- [H5 Repository Metadata Fixtures & Offline Harness (Planning)](H5_RepositoryMetadataFixtures.md)
- [D4-LNX Linux Release Packaging Matrix](../TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/)
