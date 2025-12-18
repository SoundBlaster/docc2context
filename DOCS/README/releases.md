# Releases

## Release gates

Run release gates before tagging a release:

```bash
Scripts/release_gates.sh
```

## Packaging

Release packaging is driven by:

```bash
Scripts/package_release.sh
```

## Artifact naming conventions

The README installation guidance is validated by tests to match the artifacts produced by the packaging scripts.

- Linux tarballs include `docc2context-` and `-linux-`
- Debian packages include `docc2context_` and `_linux_`
- macOS zips include `docc2context-v` and `-macos-`

## macOS install + notarization notes

- Homebrew tap: `brew tap docc2context/tap` then `brew install docc2context`
- Manual install helper: `Scripts/install_macos.sh`
- Codesigning: `codesign`
- Notarization: `notarytool`

