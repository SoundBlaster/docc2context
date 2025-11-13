# XP-Inspired TDD Workflow (Outside-In)

## Mission Statement

Grow docc2context—from Swift CLI skeleton to production-ready DocC-to-Markdown exporter—by iterating outside-in with strict
TDD so `main` is always releasable on macOS + Linux Swift 5.9.

## Guiding Principles

- **Outside-In Evolution:** Start with the CLI/acceptance surface (fixtures + snapshots) and only drop to integration/unit
  layers when driven by failing higher-level tests.
- **Always-Green Main:** Every commit must keep `swift test`, determinism checks, and packaging scripts green.
- **Test-First:** No production code without a failing XCTest; empty placeholders must fail immediately.
- **Incremental Learning:** Iterate in tiny slices, clarifying architecture (bundle ingest → parse → Markdown emit) only as
  tests justify.
- **Automated Delivery:** Maintain CI, release notes, and artifact publishing even when behavior is stubbed.

## Phase Loop

1. **Seed Delivery Skeleton** – Keep SwiftPM manifests, CI workflows, and release tasks runnable with minimal executable code.
2. **Write High-Level Acceptance Tests** – Describe desired CLI flows against DocC fixtures; let them fail loudly.
3. **Drive Implementation Outside-In** – Pick a failing acceptance test, add the thinnest scaffolding, then descend with new
   failing tests whenever collaborators need definition.
4. **Refine + Refactor** – After green builds, remove duplication, improve readability, and update docs while keeping tests
   comprehensive.
5. **Validate Release Readiness** – Run full test + packaging suite, verify determinism, and document behavior changes.

## Iteration Checklist

1. Select the highest-priority failing acceptance test from the workplan.
2. Add/adjust lower-layer tests exposing missing behavior.
3. Implement the simplest code to satisfy the new test.
4. Run all project checks locally; fix any red status immediately.
5. Refactor safely with tests.
6. Commit with behavior-focused message and sync docs/release notes.

## Documentation & Collaboration

- Keep architecture/readme + task notes in DOCS/INPROGRESS aligned with the current slice.
- Capture acceptance scenarios addressed, new collaborators, and refactors in the relevant task docs.
- Document rationale for solo decisions; prefer feature flags when behavior is partial.

## Definition of Done

- Tests, build, determinism, and packaging all pass locally and in CI.
- Release automation can ship current changes.
- Docs + release notes describe the behavior.
- No dangling TODO/FIXME without owner + follow-up issue.
