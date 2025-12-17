# H1 – APT/DNF Repository Hosting (Planning & Unblock Prep)

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-11-30
**Last Updated:** 2025-12-18
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
1. Finalize the hosting provider decision (Cloudsmith is already wired; Packagecloud would be new work) and confirm API readiness.
2. Provision the repository (apt + rpm formats), choose the required slugs (apt distribution/release/component; rpm distribution/release), and configure GPG signing keys per provider guidance.
3. Configure GitHub Actions secrets (`CLOUDSMITH_*`, plus any required signing/auth secrets) and enable the optional upload step in `.github/workflows/release.yml` by providing secrets.
4. Validate end-to-end against a staging/test repository:
   - Run `Scripts/publish_to_cloudsmith.sh --dry-run` against a local `dist/` directory.
   - Perform a tagged release to upload packages.
   - Verify `apt`/`dnf` installation paths and repository metadata integrity.
5. If we need musl installers via repositories, decide on a stable variant strategy (separate package names or separate repositories) and implement accordingly.

---

## 🔎 Current State Check
- **TODO:** H1 remains blocked on external credentials and repository ownership decisions; unblocked prep work has been completed via H1.1/H1.2 follow-ups.
- **INPROGRESS:** Prior blocker note at `DOCS/INPROGRESS/BLOCKED_H1_APTDNFRepositoryHosting.md` documents prerequisites and unblock conditions; this plan builds on that checklist.
- **ARCHIVE:** D4-LNX and H2/H3 archives confirm packaging artifacts and ancillary package-manager integrations already ship. Recent unblocked H1 prep work is archived under:
  - `DOCS/TASK_ARCHIVE/46_H1.1_CloudsmithPublishingVariantFiltering/` (glibc-only repository publishing; musl installers skipped by default)
  - `DOCS/TASK_ARCHIVE/47_H1.2_CloudsmithPublishSelectiveChannels/` (`--skip-deb` / `--skip-rpm` flags for staging apt-only or rpm-only uploads)

---

## 📋 Remaining Plan (Current State)
- **Service shortlisting:** Compare Cloudsmith vs Packagecloud free-tier limits, API endpoints, and CLI tooling; capture decision matrix in updated blocker note.
- **Secret inventory:** Draft required GitHub Actions secrets (API token, signing keys, repo identifiers) and storage expectations for `.github/SECRETS.md`.
- **Upload flow readiness:** Cloudsmith publishing is already implemented via `Scripts/publish_to_cloudsmith.sh` and wired as an optional release workflow step; remaining work is provider provisioning + secret configuration + validation.
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
- Confirm the provider slugs to use (especially apt `distribution/release/component`) and record the chosen values so `CLOUDSMITH_*` secrets can be set deterministically.
- Run a local dry-run against a real `dist/` output directory: `./Scripts/publish_to_cloudsmith.sh --dry-run` and keep the output for release checklists.
