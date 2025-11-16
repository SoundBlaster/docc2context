# docc2context Development Rules & Procedures

This directory contains operational rules, procedures, and setup guides that developers must follow when implementing docc2context features.

## 📋 Contents

### [SWIFT_SETUP.md](./SWIFT_SETUP.md)
**Purpose:** Ensure Swift toolchain is available before any implementation task.

**Required Before:**
- Running `swift build`
- Running `swift test` or `swift test --filter <test-name>`
- Any task in the START command workflow

**Contents:**
- Quick verification steps
- Complete installation for Ubuntu 24.04 LTS
- Automated setup script
- Troubleshooting guide
- Version pinning for CI/CD

**When to Use:** Before starting any task implementation via [DOCS/COMMANDS/START.md](../COMMANDS/START.md)

---

## 🔗 Related Documentation

- [DOCS/COMMANDS/START.md](../COMMANDS/START.md) — Full task implementation workflow (includes Swift setup requirement)
- [DOCS/COMMANDS/SELECT_NEXT.md](../COMMANDS/SELECT_NEXT.md) — Task selection workflow
- [DOCS/COMMANDS/ARCHIVE.md](../COMMANDS/ARCHIVE.md) — Task completion and archival workflow
- [DOCS/PRD/docc2context_prd.md](../PRD/docc2context_prd.md) — Product requirements
- [DOCS/workplan.md](../workplan.md) — Feature sequencing

---

## 🚀 Quick Start

1. **First Time Setup:**
   ```bash
   # Check if Swift is installed
   swift --version

   # If not found, follow SWIFT_SETUP.md
   ```

2. **Before Each Task Implementation:**
   - Verify Swift is installed
   - Read [DOCS/COMMANDS/START.md](../COMMANDS/START.md)
   - Check Swift environment: `swift build` should work

3. **During Implementation:**
   - Follow TDD workflow (red → green → refactor)
   - Run `swift test` frequently
   - Verify all tests pass before committing

---

## 📝 Notes

- These rules apply to all developers working on docc2context
- Rules should be updated if procedures change or new tools are adopted
- Keep this README in sync with the actual rules in this directory

**Last Updated:** 2025-11-17
