# B2 – Implement CLI Argument Parsing

## Objective
Replace the placeholder argument walker inside `Docc2contextCommand` with a real `swift-argument-parser`-powered implementation so that the failing CLI contract tests from task **B1** pass deterministically. This work unlocks downstream input detection (B3) plus logging/quality gates that rely on structured command inputs.

## References
- `DOCS/PRD/docc2context_prd.md` – Phase B table (task B2) plus priority metadata (High priority, 2 pts, requires swift-argument-parser).
- `DOCS/workplan.md` – Phase B sequencing showing B2 immediately after the completed B1 spec tests.
- `DOCS/todo.md` – B2 entry marked In Progress as of this selection note.
- Tests defined in `Tests/Docc2contextCoreTests/Docc2contextCLITests.swift` (B1 deliverable) describe the acceptance behaviors.

## Dependencies & Preconditions
- ✅ **B1** CLI interface tests exist and currently fail because parsing is still stubbed.
- ✅ **A2** harness utilities already exist to support CLI snapshot/failure tests.
- ⚠️ **A3** fixtures are still in progress but not a hard prerequisite for CLI argument parsing; just note that B3–B6 will require fixture availability.

## Definition of Done
1. Package manifest pulls in `swift-argument-parser` and wires it into both the library + executable targets without breaking Linux builds.
2. `Docc2contextCommand` (core target) exposes a representation that `swift-argument-parser` can drive, translating results back into the existing `Docc2contextCommandResult` type for tests.
3. `docc2context` executable entry point uses the new parser and ensures `--help`/`--version` output flows through the library helpers for deterministic logging.
4. All B1 tests pass locally via `swift test`, covering help text, missing argument failures, supported `--format` validation, and `--force` toggle behavior.
5. README/usage docs audited to confirm they reflect the implemented flags (update deferred unless gaps discovered during implementation).

## Test & Validation Plan
- Run `swift test --filter Docc2contextCLITests` iteratively until all assertions pass.
- Execute the full suite (`swift test`) to ensure no regressions in harness utilities.
- If `swift-argument-parser` adds runtime help output, capture/compare against `Docc2contextHelp.render()` to maintain deterministic text; add snapshot if necessary.

## Work Breakdown
- [ ] Add `swift-argument-parser` to `Package.swift`, update `Package.resolved` (if applicable), and regenerate LinuxMain if needed.
- [ ] Refactor `Docc2contextCommand` into a `ParsableCommand` or helper struct that uses `ArgumentParser` for validation instead of manual loops.
- [ ] Ensure `--format` validation hooks into the parser using `EnumerableFlag` or custom validation to maintain markdown-only restriction.
- [ ] Preserve the existing `Docc2contextCommandResult` interface so the current tests remain valid; extend tests if parser introduces new behaviors (e.g., version flag), but only after initial green.
- [ ] Document any follow-up tasks (e.g., CLI logging, `--version`) uncovered while integrating the parser and add TODO entries if necessary.

## Immediate Next Action
Audit `swift-argument-parser` compatibility (minimum Swift tools version vs. package's current `swift-tools-version: 6.0`) and prototype the dependency addition locally so we can scaffold the parser struct before modifying CLI tests.
