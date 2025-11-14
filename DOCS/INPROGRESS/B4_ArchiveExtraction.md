# B4 – Archive Extraction Pipeline

## Scope & Goal
- **PRD Reference:** Phase B, Task B4 "Extract Archive Inputs".
- **Objective:** When the CLI receives a `.doccarchive`, deterministically unpack it into a sanitized temporary directory whose
  path is stable across runs and automatically cleaned up after conversion.
- **Acceptance Criteria:**
  - Fixture-based tests cover archive inputs vs direct bundle directories, asserting normalized paths and cleanup.
  - Temporary extraction roots include hashing or naming rules that produce identical paths on repeated runs for the same input.
  - Extraction errors (invalid archive, missing DocC manifest, I/O failure) bubble up with descriptive messages and non-zero exit
    codes per PRD failure handling requirements.

## Dependencies & References
- **Upstream Tasks:** B1–B3 completed (CLI args, parsing, input detection). B4 builds on normalized bundle detection.
- **Reference Docs:** `DOCS/PRD/docc2context_prd.md` §Phase B table; `DOCS/workplan.md` Phase B checklist; `DOCS/todo.md` In Progress entry.
- **Fixtures:** Use existing DocC bundles under `Fixtures/` and, if needed, wrap them into deterministic `.doccarchive` zip files for tests.

## Planned Approach
1. **Author Tests First**
   - Extend the CLI/input handling test suite with new cases simulating `.doccarchive` inputs.
   - Snapshot/temporary directory helper ensures deterministic naming.
   - Verify cleanup occurs even when downstream conversion fails (use injected failure hooks).
2. **Implement Extraction Utility**
   - Introduce `ArchiveExtractor` responsible for unpacking and returning normalized paths plus cleanup handles.
   - Ensure it integrates with existing detection logic and logging hooks.
3. **Add Cleanup + Determinism Guards**
   - Hash-based folder naming derived from archive contents/path.
   - Add release gate hook verifying extraction determinism in `Scripts/release_gates.sh` if necessary.

## Open Questions / Next Steps
- Decide whether to vendor a lightweight zip helper or rely on Foundation's `FileManager` + `/usr/bin/unzip`.
- Confirm fixture archives live alongside the original bundles or are generated on the fly during tests.
- Begin implementing failing tests (next action) before touching production extraction code.
