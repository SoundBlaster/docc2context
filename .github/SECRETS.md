# GitHub Actions Secrets Configuration

This document describes the secrets required for the release workflow automation, including Homebrew tap publishing.

## Required Secrets

### TAP_REPO_TOKEN

**Purpose:** Enables the release workflow to automatically publish Homebrew formula updates to the tap repository.

**Type:** GitHub Personal Access Token (PAT) or GitHub App token

**Scope Required:**
- `repo` (full repository access) for the tap repository
- OR `contents: write` permission if using fine-grained PAT

**Setup Instructions:**

1. **Create a Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Give it a descriptive name: `docc2context-tap-automation`
   - Set expiration (recommend: 1 year or no expiration for automation)
   - Select scopes:
     - ✅ `repo` (all repository permissions)
   - Click "Generate token"
   - **Important:** Copy the token immediately (you won't see it again)

2. **Add Token to Repository Secrets:**
   - Go to the main repository: `SoundBlaster/docc2context`
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `TAP_REPO_TOKEN`
   - Value: Paste the token you generated
   - Click "Add secret"

**Alternative - Using GitHub App:**
For enhanced security, you can use a GitHub App token instead of a PAT:
- Create a GitHub App with `contents: write` permission for the tap repository
- Install the app on the tap repository
- Use the app's credentials in the workflow

**Important:**
`TAP_REPO_TOKEN` is required for the tap publishing workflow to function. If this secret is not configured, the workflow will fail with a clear error message. This is intentional to ensure proper configuration rather than silently failing with insufficient permissions.

## Tap Repository Configuration

The release workflow expects the tap repository to exist at:
```
SoundBlaster/homebrew-tap
```

**Repository Structure:**
```
homebrew-tap/
├── Formula/
│   └── docc2context.rb
└── README.md
```

**Branch:** The workflow pushes to the `main` branch by default.

## Verification

After configuring the secrets, you can verify the setup:

1. **Check Secret Exists:**
   - Go to repository Settings → Secrets and variables → Actions
   - Confirm `TAP_REPO_TOKEN` is listed

2. **Test with Manual Release (Dry Run):**
   - The script `Scripts/push_homebrew_formula.sh` supports `--dry-run` mode
   - You can test locally without pushing to the tap:
     ```bash
     ./Scripts/push_homebrew_formula.sh \
       --formula dist/homebrew/docc2context.rb \
       --tap-repo https://github.com/SoundBlaster/homebrew-tap.git \
       --version v1.0.0 \
       --dry-run
     ```

3. **Test with Actual Release:**
   - Create a test tag: `git tag v0.0.1-test && git push origin v0.0.1-test`
   - Monitor the release workflow in Actions tab
   - Check that the formula is updated in the tap repository

## Security Considerations

- **Token Rotation:** Personal Access Tokens should be rotated periodically (e.g., annually)
- **Minimal Scope:** The token only needs write access to the `homebrew-tap` repository
- **Audit Logs:** GitHub provides audit logs for PAT usage
- **Secret Masking:** GitHub Actions automatically masks secret values in logs

## Troubleshooting

### Error: "refusing to allow a Personal Access Token to create or update workflow"
- **Cause:** PAT lacks necessary permissions or workflow permissions are disabled
- **Solution:** Ensure PAT has `repo` scope and workflow permissions are enabled in repository settings

### Error: "Authentication failed"
- **Cause:** Token is invalid, expired, or not configured
- **Solution:** Regenerate token and update repository secret

### Error: "Could not resolve to a Repository"
- **Cause:** Token doesn't have access to the tap repository
- **Solution:** Ensure the token owner has write access to `SoundBlaster/homebrew-tap`

### Formula not updated after release
- **Cause:** Workflow conditions might not be met (only runs on tag pushes starting with `v`)
- **Solution:** Check workflow logs in Actions tab, verify tag format (e.g., `v1.0.0`)

## Related Documentation

- [GitHub Actions Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub PAT Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Homebrew Tap Documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
