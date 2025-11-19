## Next Step 1: Tap & Signing Coordination (D4-MAC)

1. **Homebrew tap**  
   - Choose the tap repository (e.g., `docc2context/homebrew-tap` or upstream `homebrew-core`).  
   - Ensure the tap exists and that the release automation user has `write` access so `.github/workflows/release.yml` can upload `dist/homebrew/docc2context.rb`.  
   - Record the exact repo URL and required permissions in `DOCS/INPROGRESS/26_D4-MAC_MacReleaseChannels.md` (or the relevant STATE update).  
   - Trigger the release workflow once to verify it can push the generated formula (you can target a temporary tag or branch).

2. **macOS signing & notarization secrets**  
   - Gather the credentials: `MACOS_SIGN_IDENTITY` (Developer ID Application certificate) and App Store Connect API key info for `notarytool` (`NOTARYTOOL_PROFILE` or similar).  
   - Store them as repository secrets with minimal scope and ensure the macOS runner can access them.  
   - Document how to refresh or rotate those secrets in `README.md`/`DOCS/INPROGRESS/26_D4-MAC_MacReleaseChannels.md` so future releases remain reproducible.  
   - Add an optional dry-run step in the release workflow to assert the secrets and keychain setup are ready before attempting codesign/notarization.
