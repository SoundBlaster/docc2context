# F8 — CI Self-Docs Markdown Artifact

## Task ID & Classification
- **Task ID**: F8 (Feature track — self-inspection/feedback loop)
- **Phase**: C (Markdown Generation) — GitHub Actions workflow for artifact generation
- **Priority**: P1 (useful for development feedback; blocks nothing else)
- **Owner**: docc2context agent (unassigned for execution)

---

## Motivation

Developers and maintainers want quick visual feedback on how the converter renders documentation. Currently, this requires:
1. Running `docc2context` locally against `Fixtures/Docc2contextCore.doccarchive`
2. Inspecting the output manually
3. Committing or discarding changes

A CI job that automatically runs the converter on committed fixtures and uploads output as a build artifact allows:
- Quick artifact review in GitHub Actions UI (no local build required)
- Visual inspection of symbol pages, articles, tutorials side-by-side with PRs
- Verification that fixture updates produce expected Markdown changes
- Fast feedback loop for documentation-related changes

---

## Acceptance Criteria

1. **GitHub Actions CI Job** — New workflow/job that:
   - Runs on every push to `main` branch (or manual trigger)
   - Executes `docc2context` against `Fixtures/Docc2contextCore.doccarchive`
   - Writes output to a deterministic directory in the runner workspace

2. **Artifact Upload** — Job uploads:
   - At minimum: the generated `markdown/` subtree
   - Optional: also upload `linkgraph/` for link graph inspection
   - Retention: default GitHub Actions retention (90 days)

3. **Offline-Friendly** — Job must:
   - Use only committed fixtures (no DocC generation, no external downloads)
   - Run without network access to external services
   - Produce deterministic output (hashes/sizes stable across runs)

4. **No Repo Mutation** — Job must:
   - Not commit generated outputs back to repository
   - Not modify any repository files (read-only fixture usage)
   - Produce artifacts as workflow outputs only

5. **Documentation** — Update:
   - GitHub Actions workflow file with clear job description
   - README with guidance on accessing self-docs artifacts
   - Optionally: workflow summary showing artifact links

6. **Coverage & Quality** — Maintain:
   - All existing tests passing (no test changes for F8)
   - Test coverage unchanged (F8 is infrastructure-only)
   - Determinism verified (dual-run consistency of artifact hashes)

---

## Scope & Non-Goals

### In Scope
- Create new GitHub Actions workflow job for self-docs generation
- Configure artifact upload for `markdown/` output
- Test the workflow with manual dispatch or push trigger
- Document the feature in README

### Out of Scope
- Automated comparisons between main and PR branches (future task)
- Web UI for browsing artifacts (GitHub Actions built-in suffices)
- Performance benchmarking in CI (separate from F8)
- Integration with external documentation services
- Committing artifacts to repository

---

## Dependencies & Preconditions

✅ **All satisfied:**
- `Fixtures/Docc2contextCore.doccarchive` is committed and ready to use
- GitHub Actions workflows already exist (`.github/workflows/`)
- Release gates scripts verified the converter works reliably
- CI pipeline infrastructure (runners, checkout actions) in place
- Swift toolchain pinning documented in existing workflows

---

## Implementation Plan

### Phase 1: Design & Planning

1. **Review existing GitHub Actions workflows**:
   - Examine `.github/workflows/ci.yml` or similar for job structure
   - Identify the standard Swift build/test patterns used
   - Note any special environment setup (caching, toolchain pins)

2. **Determine workflow trigger**:
   - Option A: Run on every push to `main` (catch regressions early)
   - Option B: Run on schedule (nightly/weekly, less frequent)
   - Option C: Manual dispatch only (dev convenience)
   - **Recommendation**: Option A (on `main` push) for best feedback loop

3. **Plan artifact retention**:
   - Use GitHub Actions default (90 days) or custom shorter duration?
   - How many artifact versions to keep? (typically all within retention period is fine)

### Phase 2: Implement Workflow Job

1. **Create or extend GitHub Actions workflow**:
   - Add new job: `self-docs-artifact` (or `generate-self-docs`)
   - Trigger: `on: push: branches: [main]` (or adjust as needed)
   - Steps:
     - Check out repository
     - Setup Swift (reuse existing toolchain setup)
     - Run: `swift run docc2context Fixtures/Docc2contextCore.doccarchive --output /tmp/self-docs --force`
     - Upload artifact: `actions/upload-artifact@v4` with `markdown/` directory

2. **Configure artifact upload**:
   - Path: `/tmp/self-docs/markdown/`
   - Name: `docc2context-self-docs` (or similar)
   - Retention days: default (90) or custom (e.g., 30)

3. **Add error handling**:
   - Fail the job if `docc2context` exits with non-zero code
   - Include summary output or log snippet showing success

### Phase 3: Test & Validate

1. **Local test** (optional but recommended):
   - Run the converter command manually to verify determinism
   - Confirm output structure and file counts
   - Check for any non-deterministic elements (timestamps, file ordering)

2. **CI test**:
   - Push a commit to a test branch and run workflow manually
   - Verify artifact is created and downloadable
   - Inspect artifact contents (spot-check a few Markdown files)

3. **Documentation**:
   - Update README with "Self-Docs Artifacts" section explaining:
     - Where to find artifacts (GitHub Actions → Artifacts dropdown)
     - What files are included
     - How to use them for review/feedback

### Phase 4: Finalize

1. **Merge workflow to main**:
   - Ensure workflow file passes linting (if applicable)
   - No breaking changes to existing CI

2. **Document in wiki/README**:
   - Add section explaining CI self-docs feature
   - Include screenshot or link to typical artifact

3. **Update task tracking**:
   - Mark F8 complete in `DOCS/todo.md`
   - Archive this planning document

---

## Success Metrics

- ✅ GitHub Actions workflow executes successfully on `main` push
- ✅ Artifact `docc2context-self-docs` is created and downloadable
- ✅ Artifact contains `markdown/` directory with symbol pages, articles, tutorials
- ✅ File counts and sizes are consistent across multiple runs (determinism verified)
- ✅ All existing tests still passing (no regressions)
- ✅ README documents the self-docs feature
- ✅ No repository files modified by the job (read-only operation)

---

## Fixtures & Test Data

**Primary fixture**: `Fixtures/Docc2contextCore.doccarchive`
- Already committed and stable
- Used for snapshot tests, coverage validation
- Provides realistic symbol/article/tutorial content for visual inspection

---

## Implementation Evidence (To Be Recorded)

- [ ] GitHub Actions workflow file: `.github/workflows/self-docs.yml` or extended existing workflow
- [ ] Workflow job: `self-docs-artifact` (or similar name)
- [ ] Artifact upload: configured to capture `markdown/` directory
- [ ] README: updated with "Self-Docs Artifacts" section
- [ ] CI validation: workflow executes successfully on test push
- [ ] Determinism check: artifact hash consistency verified

---

## Unblock Conditions

F8 does not block any other tasks. It improves the development workflow but is purely optional.

---

## Current State

- **Status**: Ready to start (via START.md command)
- **Estimated Effort**: 1–2 hours (workflow creation, testing, documentation)
- **Risk Level**: Very low (CI-only, no code changes, isolated to GitHub Actions config)
- **Documentation**: This file

---

## Next Steps (START Phase)

1. Review existing `.github/workflows/` structure and toolchain setup
2. Create new workflow file or extend existing one with self-docs job
3. Configure `docc2context` invocation and artifact upload
4. Test workflow with manual dispatch or test branch push
5. Verify artifact contents match expectations
6. Update README with self-docs feature documentation
7. Update todo.md to mark F8 complete
8. Archive this planning note

---

## References

- **PRD**: `DOCS/PRD/docc2context_prd.md` §5 (F8 feature table and acceptance criteria)
- **Fixture**: `Fixtures/Docc2contextCore.doccarchive`
- **Existing Workflows**: `.github/workflows/*.yml`
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Upload Artifact Action**: https://github.com/actions/upload-artifact
