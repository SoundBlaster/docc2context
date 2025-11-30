# H3 Additional Package Manager Integration — Arch Linux AUR PKGBUILD

- **Owner:** docc2context agent
- **Status:** Completed — 2025-11-29
- **Goal:** Deliver an offline-friendly Arch Linux packaging path that reuses released Linux tarballs/checksums without introducing new hosting infrastructure while H1 apt/dnf repository work remains blocked.

## Summary
- Added `Scripts/build_aur_pkgbuild.py`, a deterministic generator that templates PKGBUILDs from the published x86_64/aarch64 tarball URLs and SHA-256 hashes. The generator normalizes versions (strips leading `v`), uses architecture-specific `source_*` arrays, and installs `docc2context`, `README.md`, and `LICENSE` into the same layout as existing Debian/RPM artifacts.
- Introduced `AurPkgbuildScriptTests` to verify the script exists, handles missing arguments, and emits PKGBUILD content with the expected sources, checksums, and install paths.
- Documented maintainer usage in `README.md`, including a `makepkg` workflow that keeps checksum verification explicit and remains offline-friendly.

## Testing
- `swift test --filter AurPkgbuildScriptTests`

## Follow-ups
- Optional: wire the PKGBUILD generator into CI to publish to AUR once maintainer credentials and publishing cadence are defined.
- Revisit broader package manager coverage (Nixpkgs, apt/dnf repositories) when H1 unblock conditions are met.
