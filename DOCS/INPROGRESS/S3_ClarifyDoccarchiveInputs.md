# S3 – Clarify `.doccarchive` Inputs in Public Docs

**Status:** Planning (SELECT_NEXT)
**Date:** 2025-12-18
**Owner:** docc2context agent
**Depends On:** None (documentation-only)

---

## 🎯 Intent

Remove remaining ambiguity in user-facing documentation about what “`.doccarchive` input” means:

- `.doccarchive` **directory**: supported (treated as a DocC bundle directory)
- `.doccarchive` **file**: rejected with extraction guidance (current CLI contract)

S2 aligned PRD/workplan checklists, but `README.md` and a PRD example still use “`.doccarchive`” in a way that can be read as either a directory or a file.

---

## ✅ Selection Rationale

- **Operator clarity:** Users should not assume a `.doccarchive` file will be auto-extracted.
- **Doc consistency:** Align README + PRD examples with the tested contract and avoid confusion when onboarding contributors.
- **Low-risk:** Docs-only change; no behavior changes.

---

## ✅ Scope for START

1. Update `README.md` CLI usage description to explicitly say:
   - input is a DocC **directory** (including `.doccarchive` directories)
   - `.doccarchive` files must be extracted first (reference the existing CLI error message)
2. Update `DOCS/PRD/docc2context_prd.md` user-flow example to clarify that `MyDocs.doccarchive` is a directory (or use a directory path example).
3. Run `python3 Scripts/lint_markdown.py` on touched docs.

---

## ✅ Success Criteria

- README and PRD examples are unambiguous about directory vs file.
- No code changes; `swift test` remains unaffected.

---

## 📎 References

- `README.md` (CLI usage)
- `DOCS/PRD/docc2context_prd.md` (user-flow example)
- `Sources/Docc2contextCore/InputLocationDetector.swift` (error text: “archive file; extract it before converting”)
- `Tests/Docc2contextCoreTests/Docc2contextCLITests.swift` (contract test for archive file guidance)

