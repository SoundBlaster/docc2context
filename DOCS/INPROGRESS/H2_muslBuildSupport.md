# H2 – musl Build Support

**Status:** 📋 PLANNING (Selected via SELECT_NEXT)
**Date:** 2025-11-26 (Planning)
**Owner:** docc2context agent
**Depends On:** D4-LNX (✅ complete — Linux release packaging matrix)
**Phase:** F – Performance & Enhancements (Stretch Goals)

---

## 📋 Scope

Explore and implement static musl builds for universal Linux compatibility across glibc-diverse distributions. This enhancement enables `docc2context` binaries to run on Alpine Linux, older distributions with legacy glibc versions, and environments where glibc version mismatches cause runtime linking failures.

---

## 🎯 Goals

1. **Universal Linux Compatibility** — Produce static or musl-linked binaries that run on any Linux distribution without glibc version dependencies
2. **Distribution Simplicity** — Single binary works across Ubuntu, Debian, Fedora, Alpine, CentOS/RHEL, Arch, etc.
3. **CI Integration** — Automated musl builds in release workflow alongside existing glibc builds
4. **Documentation** — Clear guidance for users on when to choose musl vs glibc binaries

---

## 📐 Implementation Strategy

### Phase 1: Research & Feasibility Assessment

**Goal:** Validate musl toolchain compatibility with Swift and project dependencies

**Tasks:**
- [ ] Research Swift musl support status (Swift 5.9+ musl builds, known limitations)
- [ ] Identify musl-compatible Swift toolchains (official Swift musl snapshots vs custom builds)
- [ ] Assess SwiftPM dependency compatibility with musl (swift-argument-parser, Foundation)
- [ ] Test minimal "Hello World" Swift program with musl toolchain
- [ ] Document findings in this file (feasibility, blockers, workarounds)

**Acceptance Criteria:**
- Research summary documents Swift musl status and toolchain availability
- Test build proves Swift + musl compilation is viable (or documents blockers)
- Decision recorded: proceed with full implementation OR defer pending Swift musl maturity

**Risk Assessment:**
- **High Risk:** Swift musl support may be incomplete or require nightly toolchains
- **Medium Risk:** Foundation or other dependencies may have musl compatibility issues
- **Mitigation:** Document blockers clearly; defer if insurmountable without upstream Swift changes

### Phase 2: Development Environment Setup

**Goal:** Configure musl build toolchain locally and in CI

**Tasks:**
- [ ] Install musl toolchain (e.g., Alpine Linux container, musl-gcc, Swift musl snapshot)
- [ ] Create Docker/Podman build environment for reproducible musl builds
- [ ] Test compilation: `swift build --static-swift-stdlib` or equivalent musl flags
- [ ] Verify binary static linkage: `ldd <binary>` should show "not a dynamic executable" or minimal deps
- [ ] Document build environment setup in `DOCS/INPROGRESS/H2_muslBuildSupport.md`

**Acceptance Criteria:**
- Local musl build produces functional `docc2context` binary
- Binary runs on multiple distributions (Ubuntu, Alpine, Fedora) via container tests
- Build environment documented for reproducing locally

### Phase 3: CI Matrix Integration

**Goal:** Automate musl builds in GitHub Actions release workflow

**Tasks:**
- [ ] Extend `.github/workflows/release.yml` with musl build job
  - Use Alpine Linux container or Swift musl Docker image
  - Run `swift build -c release` with static linking flags
  - Upload artifacts: `docc2context-<version>-linux-<arch>-musl.tar.gz`
- [ ] Generate SHA256 checksums for musl artifacts
- [ ] Add musl binary to release asset list alongside glibc builds
- [ ] Test CI workflow with dry-run release (non-tag push)

**Acceptance Criteria:**
- CI successfully builds and uploads musl artifacts on tag pushes
- musl binaries downloadable from GitHub Releases
- Checksums validated post-upload

### Phase 4: Testing & Validation

**Goal:** Verify musl binaries work across diverse Linux environments

**Tasks:**
- [ ] Create test matrix: Alpine, Ubuntu 20.04, Fedora 38, Debian 11, CentOS 7
- [ ] Test musl binary execution in each environment (container-based)
- [ ] Run fixture-based smoke tests: `docc2context Fixtures/TutorialCatalog.doccarchive --output /tmp/test`
- [ ] Validate determinism: musl builds produce identical output to glibc builds
- [ ] Document test results in validation section below

**Acceptance Criteria:**
- musl binary runs successfully on all tested distributions
- No runtime linking errors or missing library failures
- Output matches glibc build outputs (determinism preserved)

### Phase 5: Documentation & User Guidance

**Goal:** Update README and release notes with musl binary guidance

**Tasks:**
- [ ] Update README Installation section:
  - Add "Linux (musl / universal)" subsection
  - Document when to use musl vs glibc builds (Alpine, old distros, compatibility issues)
  - Include curl/tar download snippet for musl tarballs
- [ ] Update release notes template (`.github/RELEASE_TEMPLATE.md`):
  - List musl artifacts alongside glibc packages
  - Explain musl benefits (universal compatibility)
- [ ] Add troubleshooting entry: "Binary won't run — try musl build"
- [ ] Document build process in `Scripts/README.md` or inline comments

**Acceptance Criteria:**
- README clearly explains musl vs glibc binary choice
- Users can self-service select appropriate binary for their environment
- Release notes template includes musl artifact references

---

## ✅ Acceptance Criteria (Overall)

- [ ] **Feasibility validated** — Research confirms Swift musl builds are viable (or blockers documented)
- [ ] **Local builds work** — musl binary compiles and runs across test distributions
- [ ] **CI automation** — Release workflow produces musl artifacts on tagged releases
- [ ] **Testing complete** — musl binaries validated on ≥4 diverse Linux distributions
- [ ] **Documentation updated** — README, release notes, and build docs cover musl option
- [ ] **Determinism preserved** — musl builds produce byte-identical outputs to glibc builds (fixture-based validation)
- [ ] **Release artifact naming** — `docc2context-<version>-linux-<arch>-musl.tar.gz` follows conventions

---

## 📚 Reference Materials

- **D4-LNX Archive** – `DOCS/TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/` (glibc packaging baseline)
- **Release Workflow** – `.github/workflows/release.yml` (current CI matrix)
- **PRD §4.6** – Release packaging requirements (musl mentioned as stretch goal)
- **Swift musl Resources:**
  - Swift.org Forums: musl support discussions
  - Swift Docker images with musl toolchains
  - Alpine Linux Swift package (if available)

---

## 🔄 Estimated Effort & Complexity

- **Effort:** 3–5 pts (depends on Swift musl maturity; higher if workarounds needed)
- **Risk:** Medium-High (Swift musl support may be experimental or incomplete)
- **Parallelizable:** Partially (research and local setup can proceed independently; CI integration sequential)

---

## 🚀 Next Steps (For START Phase)

**DO NOT IMPLEMENT DURING SELECT_NEXT — This is planning only!**

When executing via `START` command:

1. **Phase 1: Research** — Investigate Swift musl support, toolchain availability
2. **Phase 2: Local Setup** — Build musl binary locally, test on multiple distros
3. **Phase 3: CI Integration** — Extend release workflow with musl job
4. **Phase 4: Validation** — Comprehensive cross-distro testing
5. **Phase 5: Documentation** — Update README, release notes, build guides
6. **Commit & Push** — Commit changes to feature branch, push to remote
7. **Validation Gates** — Run `swift test`, release gates, determinism checks

---

## 📝 Open Questions & Research Notes

### Q1: Swift musl Toolchain Availability
- **Status:** TO BE RESEARCHED
- **Question:** Are official Swift musl toolchains available for Swift 5.9+?
- **Leads:** Check swift.org downloads, Swift Docker images, Alpine packages

### Q2: Foundation musl Compatibility
- **Status:** TO BE RESEARCHED
- **Question:** Does Swift Foundation work reliably with musl, or are workarounds needed?
- **Leads:** Search Swift Forums for musl + Foundation issues

### Q3: Static Linking Flags
- **Status:** TO BE RESEARCHED
- **Question:** What SwiftPM flags produce fully static musl binaries?
- **Options:** `--static-swift-stdlib`, custom linker flags, Swift build configuration

### Q4: Dependency Compatibility
- **Status:** TO BE RESEARCHED
- **Question:** Are swift-argument-parser and other deps musl-compatible?
- **Validation:** Build test project with dependencies in musl environment

### Q5: Performance & Binary Size
- **Status:** TO BE MEASURED
- **Question:** Do musl builds have performance or size trade-offs vs glibc?
- **Validation:** Compare binary sizes, run benchmarks (profile_memory.sh)

---

## 🔗 Cross-References

- **Phase F Enhancements:** `DOCS/workplan.md` §Phase F (performance & enhancements)
- **Linux Packaging:** `DOCS/TASK_ARCHIVE/25_D4-LNX_LinuxReleasePackagingMatrix/`
- **Release Workflow:** `.github/workflows/release.yml`
- **PRD §4.6:** Release packaging & distribution requirements
- **TODO List:** `DOCS/todo.md` (H2 entry)

---

## 🎯 Success Metrics

- **User Impact:** Users report successful installation on Alpine, old CentOS, other challenging distros
- **Artifact Availability:** musl binaries appear in every GitHub release alongside glibc packages
- **Support Reduction:** Fewer "binary won't run" issues due to glibc version mismatches
- **Determinism:** No regressions in output determinism (musl outputs match glibc outputs)

---

## ⚠️ Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|---------|------------|
| Swift musl support incomplete | Medium | High | Research first; defer if blockers found |
| Toolchain unavailable for Swift 5.9+ | Low | High | Use Docker images or nightly builds |
| Foundation incompatibilities | Low | Medium | Document workarounds or file Swift bug reports |
| Binary size increase | Medium | Low | Accept trade-off; static linking inherently larger |
| CI build time increase | Medium | Low | Run musl builds in parallel with glibc jobs |

---

## 📊 Decision Log

### 2025-11-26: Task Selected via SELECT_NEXT
- **Decision:** Select H2 musl Build Support as next planning task
- **Rationale:**
  - D4-LNX dependencies satisfied ✅
  - Not blocked by external services (unlike H1)
  - Adds practical value for Linux users (universal compatibility)
  - H3 depends on blocked H1, making H2 more viable
  - Fits Phase F enhancement goals
- **Next Step:** Create this planning document, update TODO.md, then await START command

---

## 🏁 Definition of Done

This task is **complete** when:

1. ✅ Feasibility research documented with clear go/no-go decision
2. ✅ musl builds integrated into CI release workflow (if feasible)
3. ✅ musl binaries tested on ≥4 diverse Linux distributions
4. ✅ README and release docs updated with musl guidance
5. ✅ All tests pass (`swift test`, release gates, determinism checks)
6. ✅ At least one release published with musl artifacts
7. ✅ Task archived in `DOCS/TASK_ARCHIVE/33_H2_muslBuildSupport/`
8. ✅ ARCHIVE_SUMMARY.md updated with completion entry

---

**STATUS:** Ready for START phase execution after planning approval.
