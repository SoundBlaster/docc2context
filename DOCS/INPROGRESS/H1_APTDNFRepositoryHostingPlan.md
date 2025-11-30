# H1 – APT/DNF Repository Hosting (Planning & Unblock Prep)

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-11-30
**Owner:** docc2context agent
**Depends On:** D4-LNX packaging artifacts (complete), maintainer-provided repository service + signing credentials

---

## 🎯 Intent

Re-evaluate the blocked H1 goal and outline concrete, actionable steps that reduce lead time once repository hosting credentials are available. The focus is to keep Linux distribution work unblocked by preparing service selection criteria, CI/script scaffolding, and documentation placeholders without touching code.

---

## ✅ Selection Rationale
- **Phase integrity:** Builds on completed Phase D packaging (D4-LNX) without advancing new feature code.
- **Dependency awareness:** Execution remains blocked by external credentials; planning now will shorten the handoff once the maintainer provisions access.
- **Determinism guardrails:** Any future scripts will mirror existing release gating (hash validation + fixture checks) and run after `Scripts/release_gates.sh`.
- **Doc sync:** Enables forthcoming README/SECRETS updates describing repository setup, keeping installation docs consistent with H2/H3 improvements.

---

## 📐 Scope for START
When START is invoked, the task should:
1. Select a repository hosting provider (Cloudsmith vs Packagecloud) with documented rationale and API readiness check.
2. Introduce an upload helper (likely `Scripts/publish_to_repositories.sh` or similar) that publishes `.deb`/`.rpm` artifacts after release gates succeed, with dry-run and determinism checks.
3. Extend `.github/workflows/release.yml` to call the helper on tagged releases once secrets are present.
4. Update README with repository add/install instructions and `.github/SECRETS.md` with required secrets + key handling.
5. Validate end-to-end using a test channel/repo, capturing logs and hashes for determinism parity with existing artifacts.

---

## 🔎 Current State Check
- **TODO:** No active entries; H1 listed as blocked. This note moves planning forward while acknowledging execution remains blocked.
- **INPROGRESS:** Prior blocker note at `DOCS/INPROGRESS/BLOCKED_H1_APTDNFRepositoryHosting.md` documents prerequisites and unblock conditions; this plan builds on that checklist.
- **ARCHIVE:** D4-LNX and H2/H3 archives confirm packaging artifacts and ancillary package-manager integrations already ship.

---

## 📋 Proposed Plan (No code yet)
- **Service shortlisting:** Compare Cloudsmith vs Packagecloud free-tier limits, API endpoints, and CLI tooling; capture decision matrix in updated blocker note.
- **Secret inventory:** Draft required GitHub Actions secrets (API token, signing keys, repo identifiers) and storage expectations for `.github/SECRETS.md`.
- **Upload flow design:** Sketch CLI for a future `publish_to_repositories` helper (arguments, dry-run mode, deterministic logging) to align with existing release scripts.
- **Test strategy:** Define validation steps (hash check post-upload, `apt`/`dnf` install from test repo, retry semantics) to encode later as XCTests or integration checks.
- **Doc placeholders:** Identify README sections needing updates (Linux package manager install) and any operator guide additions.

---

## 🚧 Blockers & Risks
- **External credentials required:** Cannot execute uploads or signing without maintainer-provided accounts and keys.
- **Service lock-in:** Provider choice impacts CI scripting; planning will hedge by keeping upload helper provider-agnostic where possible.
- **Security:** Handling of signing keys and API tokens must follow `.github/SECRETS.md` conventions; no secrets will be added during planning.

---

## 🔜 Next Actions Before START
- Update `DOCS/todo.md` to mark H1 planning in progress and reference this note.
- Enrich `BLOCKED_H1_APTDNFRepositoryHosting.md` with provider comparison and secret inventory (follow-up after maintainer feedback).
- Prepare outline for `publish_to_repositories` helper and release workflow hook so implementation can begin immediately once credentials exist.

