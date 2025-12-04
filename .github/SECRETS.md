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

## Cloudsmith Repository Publishing

### CLOUDSMITH_API_KEY

**Purpose:** Authenticates the Cloudsmith CLI/API for uploading `.deb`/`.rpm` packages from the release workflow.

**Type:** Cloudsmith API token scoped to the target repository.

**Setup Instructions:**

1. Sign in to Cloudsmith and navigate to **Your Profile → API Keys**.
2. Create a new key (recommended name: `docc2context-release`), scoped to the organization that will host the repository.
3. Copy the token value.
4. Add it as a repository secret named `CLOUDSMITH_API_KEY` under Settings → Secrets and variables → Actions.

### CLOUDSMITH_OWNER / CLOUDSMITH_REPOSITORY

**Purpose:** Identify the Cloudsmith owner/organization slug and repository slug used by the upload helper.

**Setup Instructions:**

1. Create (or select) the target Cloudsmith repository for apt/dnf hosting.
2. Note the **owner** slug (e.g., `soundblaster`) and **repository** slug (e.g., `docc2context`).
3. Add both values as repository secrets `CLOUDSMITH_OWNER` and `CLOUDSMITH_REPOSITORY`.

### CLOUDSMITH_APT_DISTRIBUTION / CLOUDSMITH_APT_RELEASE / CLOUDSMITH_APT_COMPONENT

**Purpose:** Configure Debian upload metadata for `cloudsmith push deb`.

- `CLOUDSMITH_APT_DISTRIBUTION`: distro slug (e.g., `ubuntu`)
- `CLOUDSMITH_APT_RELEASE`: release codename (e.g., `jammy`)
- `CLOUDSMITH_APT_COMPONENT`: component name (e.g., `main`)

**Setup Instructions:**

1. In Cloudsmith, ensure the apt repository is configured for the chosen distribution/release.
2. Add the distribution, release, and component values as repository secrets.
3. If unset, the upload helper defaults to `ubuntu/jammy` and `main`.

### CLOUDSMITH_RPM_DISTRIBUTION / CLOUDSMITH_RPM_RELEASE

**Purpose:** Configure RPM upload metadata for `cloudsmith push rpm`.

- `CLOUDSMITH_RPM_DISTRIBUTION`: distro slug (e.g., `any-distro` or `centos`)
- `CLOUDSMITH_RPM_RELEASE`: release identifier (e.g., `any-version` or `7`)

**Setup Instructions:**

1. Align slugs with the RPM repository configuration inside Cloudsmith.
2. Add the values as repository secrets; defaults (`any-distro` / `any-version`) are used if unset.

### Activation checklist (Cloudsmith)

- [ ] Repository owner/repo created in Cloudsmith with apt/dnf formats enabled
- [ ] `CLOUDSMITH_API_KEY` secret added
- [ ] `CLOUDSMITH_OWNER` and `CLOUDSMITH_REPOSITORY` secrets added
- [ ] Distribution/release/component secrets set (or confirm defaults are acceptable)
- [ ] Optional dry-run executed locally: `./Scripts/publish_to_cloudsmith.sh --owner <owner> --repository <repo> --version vX.Y.Z --artifact-dir dist --dry-run`
- [ ] Tagged release pushed after secrets configured to exercise the Cloudsmith upload step

## Repository validation harness (apt/dnf)

The offline repository validation harness ships as `swift run repository-validation` and defaults to the in-repo fixtures. It requires **no secrets** when invoked in fixture mode. When H1 hosting is provisioned and live probes are enabled, plan to add the following secrets to keep CI inputs configurable and isolated from logs:

- `REPO_VALIDATION_APT_URL` – staging apt repository base URL for metadata checks.
- `REPO_VALIDATION_DNF_URL` – staging dnf repository base URL for metadata checks.
- `REPO_VALIDATION_GPG_KEY_PATH` – path (or mounted secret) to the trusted GPG public key used to verify InRelease signatures.

Until those secrets are defined, the validation step should continue running in fixture mode by passing `--fixtures-path Fixtures/RepositoryMetadata` through the release gates script.

## Related Documentation

- [GitHub Actions Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub PAT Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Homebrew Tap Documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
