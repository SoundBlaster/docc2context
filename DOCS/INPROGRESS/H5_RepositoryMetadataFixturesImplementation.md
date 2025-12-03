# H5 – Repository Metadata Fixtures Implementation (SELECT_NEXT Planning)

**Status:** In Progress (START)
**Date:** 2025-12-21
**Owner:** docc2context agent
**Depends On:** H1 repository hosting decisions, H4 validation harness design, D4-LNX packaging outputs, H2/H3 packaging extensions

---

## 🎯 Intent

Select and outline the concrete implementation work to build repository metadata fixtures and offline validation scaffolding for apt/dnf so the H4 validation harness can progress without live hosting. The goal is to deliver deterministic fixture sets (Release/InRelease, Packages, repomd.xml/primary.xml) plus helper tooling that mirrors Cloudsmith/Packagecloud layouts using existing `.deb`/`.rpm` artifacts and test signing keys.

---

## ✅ Selection Rationale
- **Phase integrity:** Builds on completed packaging (D4-LNX) and repository integration extensions (H2 musl, H3 AUR) without touching runtime conversion logic.
- **Dependency awareness:** Addresses the offline pieces that remain unblocked while H1 hosting credentials are pending, unlocking parallel progress on H4 validation.
- **Testing-first:** Commits to fixture-backed XCTests and script harnesses that default to offline/fixture mode, preserving determinism.
- **Doc sync:** Prepares README/SECRETS additions for repository consumers and CI operators once fixtures and validation tooling ship.

---

## 📐 Scope for START
When START executes this task, implement:
1. **Fixture generation + layout**
   - Produce deterministic apt metadata fixtures (Release, InRelease, Packages) and dnf metadata (repodata/repomd.xml, primary.xml.gz) that reference existing `.deb`/`.rpm` artifacts (glibc + musl) with matching hashes and versions.
   - Include signed and tampered variants using test GPG keys to exercise success/failure paths.
2. **Offline validation harness**
   - Add a helper script/library entry point (e.g., `Scripts/mock_repo_validator.sh` or Swift harness) that reads the fixtures, verifies signatures, and asserts package availability without network access.
   - Provide container templates (Debian/Ubuntu/Fedora) for opt-in install smoke tests against local fixture directories or staged endpoints.
3. **XCTest coverage**
   - Add deterministic tests that load the fixtures, validate signature + checksum alignment, and cover negative cases (missing packages, mismatched hashes, invalid signatures).
4. **Documentation updates**
   - Update README installation/validation sections with fixture usage and offline test commands.
   - Extend `.github/SECRETS.md` with staging URL + GPG key guidance for future live probes, keeping defaults offline-safe.

---

## 🧪 Success Metrics
- Fixture generation is deterministic (hash-stable) and documented with expected outputs per distribution/architecture.
- Offline validation harness passes on Linux/macOS without network access; CI defaults to fixture mode and skips live probes unless env flags + credentials are present.
- Tests cover success and failure scenarios for both apt and dnf metadata, including musl/glibc package variants.
- Documentation clearly links fixture usage to H4 validation and H1 hosting expectations.

---

## 🚧 Risks & Mitigations
- **Fixture fidelity:** Mitigate by cross-referencing Cloudsmith/Packagecloud metadata structures and capturing layout assumptions in comments and docs.
- **Determinism drift:** Store hash manifests alongside fixtures; add tests that regenerate and compare hashes to catch divergence.
- **Key handling:** Use dedicated test GPG keys stored under Fixtures with clear separation from production credentials; ensure scripts redact sensitive paths/outputs.
- **Coverage creep:** Keep container-based smoke tests opt-in to avoid slowing default CI while still documenting how to run them locally.

---

## ✅ Work completed during START
- Added deterministic offline apt/dnf metadata fixtures under `Fixtures/RepositoryMetadata` with a dedicated manifest tracking SHA-256 hashes and byte sizes for Release/InRelease/Packages and repodata files.
- Implemented `RepositoryMetadataFixturesValidator` to load the manifest, compute hashes/sizes, and report mismatches to support the H4 validation harness.
- Added `RepositoryMetadataFixturesTests` covering the happy path and tampering detection by mutating fixture copies in temporary directories.
- Documented the new fixtures and validation harness usage in `Fixtures/README.md` and the top-level README.

## 🔜 Next Steps
- Thread the validator into the broader repository validation harness once H4 execution begins and wire optional CI hooks that exercise the offline fixtures.
- Add signed fixture variants (GPG test keys) once hosting decisions clarify the expected trust model.
- Extend fixtures to cover additional architectures/components as package outputs expand beyond the current placeholders.

---

## 📎 References
- [PRD §4.6 Release Packaging & Distribution Requirements](../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements)
- [Workplan – Phase E/H follow-ups](../workplan.md)
- [H1 APT/DNF Repository Hosting Plan](H1_APTDNFRepositoryHostingPlan.md)
- [H4 Repository Validation Harness Implementation](H4_RepoValidationHarnessImplementation.md)
- [H5 Repository Metadata Fixtures & Offline Harness (Planning)](H5_RepositoryMetadataFixtures.md)
- [D4-LNX Linux Release Packaging Matrix](../TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/)
