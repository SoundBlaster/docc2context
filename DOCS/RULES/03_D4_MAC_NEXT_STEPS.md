## Homebrew Publishing & macOS Release Checklist (D4-MAC)

1. **Choose the tap/hosting path**  
   - Decide whether to target `homebrew-core` (upstream PR) or your own tap (e.g., `docc2context/homebrew-tap`). For faster releases and more control, maintain a private tap and keep a `README`/docs note about how to add it.
   - Ensure the tap repo is public (if you want broad discoverability) and that the release automation user has `contents: write` permission so `.github/workflows/release.yml` can upload `dist/homebrew/docc2context.rb`. Record the tap URL + branch in `DOCS/INPROGRESS/26_D4-MAC_MacReleaseChannels.md` and mention it in `STATE` updates.
   - After each release run, verify the workflow pushes the generated formula to the tap; if it fails, manually commit `dist/homebrew/docc2context.rb` with the same deterministic contents produced by `Scripts/build_homebrew_formula.py`, then push the tap repo.

2. **Artifact generation & packaging**  
   - Run `Scripts/package_release.sh --platform macos --arch arm64` and the same command for `--arch x86_64`. Each invocation should produce `docc2context-v<version>-macos-<arch>.zip`, `<zip>.sha256`, and `docc2context-v<version>-macos-<arch>.md` summary file.
   - Keep `package_release.sh` deterministic: stage `README.md`/`LICENSE`, codesign the binary when `MACOS_SIGN_IDENTITY` is set, and produce architecture-aware summary metadata so automation downstream understands which download to inject into the formula.
   - Run codesign using `codesign --options runtime --timestamp --sign "$MACOS_SIGN_IDENTITY" docc2context`. Log the identity before the call and exit if signing fails.
   - Notarize the zipped release (when credentials are available) via:
     ```bash
     xcrun notarytool submit <zip> --keychain-profile <profile> --wait
     xcrun stapler staple <zip>
     ```
     Document the profile name (`NOTARYTOOL_PROFILE`) and notarization status in the release summary.

3. **Apple credentials & secrets**  
   - Export a Developer ID Application certificate (`MACOS_SIGN_IDENTITY`) and install it into the macOS keychain accessible by the workflow. Provide the exact identity string (including team ID) as the secret so `codesign` can locate it.
   - Create an App Store Connect API key + issuer ID for `notarytool`. Store the key file (or coordinates) securely and configure either a `notarytool` profile (`NOTARYTOOL_PROFILE`) or expose `NOTARYTOOL_KEY_ID`, `NOTARYTOOL_ISSUER_ID`, `NOTARYTOOL_KEY_PATH`.
   - Add a dry-run/validation step in the workflow that checks `security find-identity -v` for the expected identity and prints whether `notarytool` can read the named profile to avoid shipping unsigned artifacts.
   - Document how to rotate secrets/certificates (e.g., re-import certificate, update GitHub secrets, rerun `security import`) in `README.md` and the D4-MAC INPROGRESS note.

4. **Generate deterministic Homebrew formula**  
   - Use `python3 Scripts/build_homebrew_formula.py` to render `dist/homebrew/docc2context.rb` with the release version, per-arch URLs, and checksums. The script produces consistent Ruby source (`desc`, `homepage`, `on_macos` blocks, `def install`, `test do`).
   - The formula structure should match Homebrew conventions so future maintainers can review/merge it easily. Keep the `test do` section minimal: `assert_match version.to_s, shell_output("#{bin}/docc2context --version")`.
   - After the workflow uploads the formula, `brew tap docc2context/tap` + `brew install docc2context` should instantly install the new release without manual edits.

5. **Documenting Homebrew usage**  
   - Update `README.md` to describe:
     1. How to add the tap (`brew tap docc2context/tap`) and install/test the binary (`brew install docc2context`, `brew test docc2context`).
     2. Manual download/install commands that choose `/opt/homebrew/bin` on arm64 vs `/usr/local/bin` on x86_64, include checksum verification, and show how to use `Scripts/install_macos.sh --dry-run`.
     3. Notarization/codesign steps (`codesign`, `xcrun notarytool submit`, `xcrun stapler staple`) plus any required environment variables/secrets.
   - Keep `Tests/Docc2contextCoreTests/DocumentationGuidanceTests.swift` in sync with the README sections so the doc tests remain green.

6. **Release verification & field testing**  
   - After publishing, run `brew tap docc2context/tap` on both Silicon and Intel hosts to ensure the tap/index resolves the new formula and that `brew install docc2context` succeeds. Add this to the release checklist.
   - Encourage testers to use `Scripts/install_macos.sh --dry-run` before performing real installs; share the checksum to guard against tampering and to confirm the downloaded zip matches the published hash.
   - Archive this D4-MAC task in `DOCS/TASK_ARCHIVE/` once the tap is flowing, secrets are documented, docs/tests are updated, and the release workflow has been executed successfully. Maintain the `DOCS/todo.md` entry until these validations are complete.
