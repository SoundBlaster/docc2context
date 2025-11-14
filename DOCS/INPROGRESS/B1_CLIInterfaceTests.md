# B1 – CLI Interface Tests

## Objective
Define the docc2context CLI contract through XCTest cases that exercise required arguments (`input`, `--output`), supported flags (`--force`, `--format`), and error messaging so that subsequent implementation work has an unambiguous specification to satisfy.

## Relevant PRD Paragraphs
- PRD §Phase B (Table row B1) – requires specifying CLI arguments and error outputs before implementation.
- PRD §4.2 Functional Requirements (Input Handling & CLI Experience) – mandates argument layout, error codes, and help messaging.

## Test Plan
- Author XCTest cases under `Tests/Docc2contextCoreTests/` describing expected exit codes, stdout/stderr text, and default behaviors.
- Exercise combinations of `docc2context <input> --output <dir> [--format markdown] [--force]`.
- Validate failures for missing input/output, unsupported formats, and attempts to overwrite existing output without `--force`.
- Execute `swift test` locally and in CI to ensure regression coverage once B2 implements the parser.

## Dependencies
- **A2 – TDD Harness utilities**: rely on shared fixture/temp directory helpers for deterministic CLI tests. Current harness partially implemented; coordinate with A2 owner for reusable utilities once ready.
- Swift Argument Parser adoption planned in B2 to satisfy the tests.

## Blocking Questions
1. Should CLI expose shorthand aliases (`-o`, `-f`) in addition to long-form flags? Need confirmation from PRD/UX perspective.
2. Confirm desired exit code for validation errors (`EX_USAGE`/64 vs generic non-zero) to encode in tests.

## Checklist
- [x] Capture scope + validation plan in this INPROGRESS note.
- [ ] Draft failing CLI tests for `--output` requirement and missing input handling.
- [ ] Add coverage for `--force` overwrite semantics and confirmation messaging.
- [ ] Specify supported formats (default `markdown`, future `json`) with failing tests for unsupported values.
- [ ] Update README/usage docs once CLI contract solidified.

## Immediate Next Action
Begin writing red tests in `Docc2contextCLITests` covering the missing input and output validation flows, using temporary directory helpers from A2 once stabilized.
