# H3 Additional Package Manager Integration — SELECT_NEXT Planning

- **Owner:** docc2context agent
- **Status:** Planning initiated 2025-11-29 via `SELECT_NEXT`; awaiting H1 unblock
- **Objective:** Identify the next package ecosystem(s) (e.g., Arch Linux AUR, Nixpkgs, Scoop/Chocolatey) that expand installation options beyond the existing tarball/DEB/RPM/Homebrew channels while preserving deterministic artifacts and offline-friendly tooling.

## Context & Dependencies
- **Upstream dependency:** H1 apt/dnf repository hosting remains blocked on external credentials; H3 execution must either (a) wait for H1 completion or (b) target ecosystems that do not require the blocked infra.
- **PRD alignment:** Distribution scope already mandates deterministic tarballs plus `.deb`/`.rpm` outputs and documented install snippets; additional package managers should consume the existing signed artifacts and semver tags without introducing new build inputs or non-deterministic steps. See PRD §4.6 packaging/distribution bullets about semver-tagged artifacts and package manager snippets.【F:DOCS/PRD/docc2context_prd.md†L129-L137】
- **Recent work:** H2 musl build support expanded Linux artifacts; reuse musl/glibc binaries to avoid rebuilding per ecosystem.

## Candidate Evaluation Criteria
- Minimal new infrastructure (prefer community-hosted repos like AUR/Nixpkgs over self-hosted unless H1 unblocks)
- Deterministic packaging scripts with snapshot/fixture tests similar to existing release helpers
- Clear maintenance story (automated updates on tag publish, documented secrets if required)
- Alignment with PRD installation guidance and existing release workflow triggers

## Planned Actions (pre-START)
1. **Scope selection:** Choose one ecosystem to pursue first (likely Arch AUR due to low infra needs; Nixpkgs if maintainer sponsorship available). Document rationale vs. H1 status.
2. **Acceptable outputs:** Define acceptance criteria (e.g., PKGBUILD template + test harness, nfpm config, or nix derivation) that reuse released tarballs and validate checksums deterministically.
3. **Testing approach:** Outline XCTest/script tests mirroring `HomebrewTapPublishScriptTests`/`PackageReleaseScriptTests` to lock naming, checksum usage, and update flows without hitting external networks.
4. **CI/automation hooks:** Identify where to integrate into release workflow once accepted (conditional jobs behind secrets/maintainer toggles).
5. **Docs impact:** Plan README/SECRETS additions (installation snippets, maintainer steps) to keep user guidance synced once implementation proceeds.

## Exit Criteria for START handoff
- Selected target ecosystem with documented reasoning and dependency status
- Draft acceptance criteria + test strategy recorded here
- TODO updated to reflect active planning state (done)
- Ready to execute [COMMANDS/START](../COMMANDS/START.md) once H1 unblock/maintainer approval is confirmed
