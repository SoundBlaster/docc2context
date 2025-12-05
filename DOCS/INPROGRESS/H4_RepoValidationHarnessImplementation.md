# H4 – Repository Validation Harness Implementation (SELECT_NEXT Planning)

**Status:** Complete (START finished; archived)
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

## ✅ Completion Summary
- Implemented `RepositoryValidationHarness` + `RepositoryValidationCommand` to validate apt/dnf metadata with fixture defaults and override flags for staged repositories; added `repository-validation` executable target.
- Added XCTests covering fixture success, tampered apt/dnf failure detection, and CLI flag behaviors.
- Wired `Scripts/release_gates.sh` to run the harness against `Fixtures/RepositoryMetadata` by default with optional `REPOSITORY_VALIDATION_FLAGS` overrides; documented usage in README and `.github/SECRETS.md`.

See `DOCS/TASK_ARCHIVE/40_H4_RepositoryValidationHarnessImplementation/` for the full archive entry.

---

## 📎 References
- [PRD §4.6 Release Packaging & Distribution Requirements](../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements)
- [Workplan – Phase E/H follow-ups](../workplan.md)
- [H1 APT/DNF Repository Hosting Plan](H1_APTDNFRepositoryHostingPlan.md)
- [H4 Repository Validation Harness (Planning)](H4_RepoValidationHarness.md)
- [H5 Repository Metadata Fixtures & Offline Harness (Planning)](H5_RepositoryMetadataFixtures.md)
- [D4-LNX Linux Release Packaging Matrix](../TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/)
