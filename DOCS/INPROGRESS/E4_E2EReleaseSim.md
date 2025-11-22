# E4 E2E Release Simulation

**Status**: Selected for planning (SELECT_NEXT)
**Date**: 2025-11-22
**Branch**: `claude/implement-select-next-01Xn2vHeU9WKqnkf9rETdczg`

---

## 📋 Task Summary

Execute the complete release workflow **end-to-end** in a test environment to validate all release gates, distribution channels, and packaging mechanics. This ensures that when a maintainer tags a release, the CI automation successfully:

1. Builds Linux and macOS binaries
2. Runs determinism checks
3. Generates signed packages (Linux `.deb`/`.rpm`, macOS `.zip`)
4. Produces Homebrew formula updates
5. Verifies artifact integrity (hashes)
6. Publishes distributions (GitHub Releases, optional Homebrew tap)

---

## 🎯 Acceptance Criteria (from PRD §Phase E)

- [ ] Execute a **simulated release workflow** locally and in CI (test environment tag) that builds all artifacts
- [ ] Validate all release gates pass: tests, determinism hashing, fixture manifest checks
- [ ] Confirm **Linux artifacts** (`docc2context-v*.tar.gz`, `.deb`, `.rpm`) are created and checksummed
- [ ] Confirm **macOS artifacts** (`docc2context-v*.zip` for arm64 + x86_64) with Homebrew formula generation
- [ ] Verify **Homebrew formula** generation produces valid Ruby syntax and installs successfully (dry-run or tap test)
- [ ] Ensure **README** installation instructions remain in sync with actual artifacts
- [ ] Document any gaps or manual steps required post-CI (e.g., tap repo provisioning, notarization workarounds)
- [ ] Confirm **no regressions** in determinism or coverage gates post-release

---

## 🔗 Dependencies

| Dependency | Status | Notes |
| --- | --- | --- |
| **E2 Homebrew Tap Publishing** | ✅ Complete | Formula push workflow ready |
| **D4 Package Distribution** | ✅ Complete | Release workflow (`release.yml`) in place |
| **D4-LNX Linux Packaging** | ✅ Complete | `build_linux_packages.sh` and CI matrix ready |
| **D4-MAC macOS Release Channels** | ✅ Complete | Arch-aware zips + Homebrew formula generation ready |
| **E3 CI Signing/Notarization Setup** | ❌ Blocked | Linux path unaffected; macOS requires manual notarization workaround for E4 |

---

## 📐 Scope & Approach

### Phase 1: Local Simulation (Manual Dry-Run)
1. Create a test release tag (e.g., `v0.1.0-test`) locally
2. Run `Scripts/package_release.sh --version 0.1.0-test --platform linux --arch x86_64 --dry-run` to simulate packaging
3. Verify all expected artifacts are reported (without actually creating them)
4. Check README install snippets match actual artifact naming conventions from scripts:
   - **Linux**: no `v` prefix (e.g., `docc2context-0.1.0-test-linux-x86_64.tar.gz`)
   - **Debian**: includes `_linux_` (e.g., `docc2context_0.1.0-test_linux_amd64.deb`)
   - **RPM**: includes `-linux-` (e.g., `docc2context-0.1.0-test-linux-x86_64.rpm`)
   - **macOS**: includes `v` prefix (e.g., `docc2context-v0.1.0-test-macos-arm64.zip`)

### Phase 2: Test Environment CI Run (If Feasible)
1. Push test branch with `v0.1.0-test` tag to test CI
2. Observe GitHub Actions `release.yml` workflow execution
3. Collect artifacts from workflow run
4. Validate artifact checksums and metadata

### Phase 3: Validation & Acceptance
1. **Linux**: Install `.tar.gz` and `.deb` on test machines; verify `docc2context --version` works
2. **macOS**: (Manual or tap test) Verify formula syntax and dry-run install
3. **Homebrew**: Test formula push to tap (if TAP_REPO_TOKEN configured) or document manual steps
4. **Determinism**: Re-run conversion on released binaries; confirm hashes match
5. **Documentation**: Ensure README + SECRETS.md accurately reflect release flow

### Phase 4: Gap Analysis & Follow-Up
1. Document any missing automation (e.g., tap repo auto-creation)
2. Flag E3 workarounds for macOS notarization
3. Propose E4 sub-tasks or backlog items if needed

---

## 🧪 Test Fixtures & Validation

| Fixture | Purpose | Owner |
| --- | --- | --- |
| `Fixtures/TutorialCatalog.doccarchive` | End-to-end conversion test input | Existing (A3) |
| `Scripts/package_release.sh` | Dry-run simulation harness | D4 / D4-LNX / D4-MAC |
| `.github/workflows/release.yml` | CI automation target | D4 |
| Test tag (`v0.1.0-test`) | Trigger CI workflow safely | E4 |

---

## 🎬 Expected Artifacts & Checklist

### Linux Artifacts
- [ ] `docc2context-0.1.0-test-linux-x86_64.tar.gz` (no `v` prefix in version)
- [ ] `docc2context-0.1.0-test-linux-x86_64.tar.gz.sha256`
- [ ] `docc2context-0.1.0-test-linux-aarch64.tar.gz` (no `v` prefix in version)
- [ ] `docc2context-0.1.0-test-linux-aarch64.tar.gz.sha256`
- [ ] `docc2context_0.1.0-test_linux_amd64.deb` (includes `_linux_` in name)
- [ ] `docc2context_0.1.0-test_linux_arm64.deb` (includes `_linux_` in name)
- [ ] `docc2context-0.1.0-test-linux-x86_64.rpm` (includes `-linux-` in name)
- [ ] `docc2context-0.1.0-test-linux-aarch64.rpm` (includes `-linux-` in name)

### macOS Artifacts
- [ ] `docc2context-v0.1.0-test-macos-arm64.zip`
- [ ] `docc2context-v0.1.0-test-macos-arm64.zip.sha256`
- [ ] `docc2context-v0.1.0-test-macos-x86_64.zip`
- [ ] `docc2context-v0.1.0-test-macos-x86_64.zip.sha256`
- [ ] Homebrew formula (Ruby, valid syntax, installs cleanly)

### Documentation Validation
- [ ] README §Installation reflects all artifact formats
- [ ] `.github/SECRETS.md` documents all required secrets for full automation
- [ ] Release notes template (`.github/RELEASE_TEMPLATE.md`) is up to date

---

## 📚 Reference Materials

- **PRD Phase E**: `DOCS/PRD/docc2context_prd.md` (§4.6 Release Packaging)
- **Workplan**: `DOCS/workplan.md` (Phase E status)
- **D4 Notes**: `DOCS/TASK_ARCHIVE/24_D4_PackageDistribution*.md`
- **D4-LNX Notes**: `DOCS/TASK_ARCHIVE/25_D4-LNX_*.md`
- **D4-MAC Notes**: `DOCS/TASK_ARCHIVE/26_D4-MAC_*.md`
- **E2 Notes**: `DOCS/TASK_ARCHIVE/28_E2_HomebrewTapPublishing/`
- **Release Workflow**: `.github/workflows/release.yml`
- **Scripts**:
  - `Scripts/package_release.sh` — Main packaging orchestrator; macOS artifacts include `v` prefix in version (line 264)
  - `Scripts/build_linux_packages.sh` — Linux-specific packaging; produces artifacts WITHOUT `v` prefix (line 199), with `_linux_` in deb names (line 229), and `-linux-` in rpm names (line 298)
  - `Scripts/build_homebrew_formula.py` — Homebrew formula generator
  - `Scripts/push_homebrew_formula.sh` — Tap publishing automation

---

## 🚧 Known Blockers & Workarounds

| Blocker | Impact | Workaround |
| --- | --- | --- |
| **E3 Apple Developer ID Credentials** | macOS notarization cannot be fully automated | Manual notarization post-release or ad-hoc signing for test |
| **Homebrew Tap Repo** | Formula push requires `TAP_REPO_TOKEN` secret | Use `--dry-run` mode or manual tap repo for E4 test |
| **Test Tag Cleanup** | `v0.1.0-test` tags pollute release history | Delete test tags after E4 completes; consider using GitHub draft releases for CI-only artifacts |

---

## 💡 Success Metrics

1. ✅ All release gates pass (tests, determinism, fixture validation)
2. ✅ Dry-run simulation produces expected artifact list
3. ✅ CI test run successfully builds all artifacts
4. ✅ Linux artifacts install and run correctly
5. ✅ macOS artifacts (manual or tap) install and run correctly
6. ✅ Homebrew formula syntax is valid
7. ✅ README installation steps match reality
8. ✅ No new test failures or coverage regressions
9. ✅ Gap analysis identifies next steps (e.g., E3 workaround, automated apt/dnf hosting)

---

## 🔄 Next Steps (Once Started)

1. **Implement local dry-run simulation** to validate `Scripts/package_release.sh`
2. **Push test tag to CI** and monitor `.github/workflows/release.yml` execution
3. **Collect and validate artifacts** against acceptance criteria
4. **Update README & docs** if discrepancies found
5. **Archive task notes** and update `DOCS/todo.md` with results
6. **Promote E4 to completed** or backlog follow-up sub-tasks (E3 workaround, automated hosting, etc.)

---

## 📝 References for Implementation (START command)

Once E4 planning is approved, the START command will:

1. Create failing test cases in `Docc2contextE2ETests` or `ReleaseWorkflowTests` covering:
   - Local dry-run artifact validation
   - CI workflow triggering (test tag)
   - Artifact integrity checks (hash verification)
   - Homebrew formula validation
2. Implement test fixtures (test tag, mock CI environment)
3. Document manual validation steps in README if automation gaps remain
4. Update `DOCS/workplan.md` and `DOCS/todo.md` upon completion

---

**Last Updated**: 2025-11-22
**Prepared by**: SELECT_NEXT
**Status**: Ready for implementation via START command
