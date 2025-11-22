# BLOCKED: E3 CI Signing/Notarization Setup

## ⛔ BLOCKER STATUS
**Status**: BLOCKED as of 2025-11-22
**Blocked by**: Apple Developer ID credentials unavailable
**Category**: External Dependencies
**Priority**: Medium (completes macOS distribution trust chain)

---

## 📋 TASK OVERVIEW
**Task ID**: E3
**Title**: CI Signing/Notarization Setup
**Objective**: Configure GitHub Actions secrets for macOS codesign identity and notarytool credentials so release workflow can produce notarized macOS binaries automatically.

**Description**:
- Configure GitHub Actions secrets for Apple Developer ID certificate and password
- Set up notarytool credentials in CI environment (`AC_USERNAME`, `AC_PASSWORD`, `NOTARY_TEAM_ID`)
- Integrate codesigning into `.github/workflows/release.yml` to sign macOS binaries with runtime hardening options
- Integrate notarization into release workflow to submit signed binaries and await approval
- Document credential provisioning steps in `.github/SECRETS.md`

**Dependencies**:
- Apple Developer ID credentials provisioning
- Completion of E2 (Homebrew Tap Publishing Automation) — ✅ Complete
- D4-MAC macOS Release Channels documentation — ✅ Complete (includes codesign/notarization guidance)

**References**:
- [D4-MAC Task Archive](../TASK_ARCHIVE/26_D4-MAC_MacReleaseChannels/) — completed with comprehensive README codesign/notarization documentation
- [PRD §4.6 macOS Packaging](../PRD/docc2context_prd.md#46-release-packaging--distribution-requirements) — notes documentation of codesigning and notarization steps
- [D4-MAC Archive Gaps Section](../TASK_ARCHIVE/26_D4-MAC_MacReleaseChannels/D4-MAC_MacReleaseChannels.md) — flagged E3 and E4 as follow-ups

---

## 🧠 BLOCKER DETAILS

### What Is Preventing Progress?
The task requires provisioning and configuring Apple Developer ID credentials:
1. **Apple Developer Program Membership**: Requires active enrollment and payment
2. **Developer ID Certificate**: An X.509 certificate for code signing, obtained through Apple Developer account
3. **Developer ID Application Certificate**: Distinct certificate for application signing (`Developer ID Application: <Name>`)
4. **App-Specific or Account Password**: Required for `notarytool` authentication with Apple's notarization service
5. **Team ID**: If using organization accounts, need team identifier for notarization API

**Current Status**: No access to Apple Developer Program account; organization/maintainer has not provisioned credentials.

### Why Is This Blocking?
Without valid Developer ID credentials, the CI/CD pipeline cannot:
- Sign binaries with cryptographic identity recognized by macOS Gatekeeper
- Submit binaries to Apple's notarization service for security scanning and approval
- Generate stapled notarization tickets that enable silent binary execution on macOS 10.15+
- Build trust chain that eliminates "Developer cannot be verified" or quarantine attribute warnings

### Impact on Workplan
- **E3 Task**: Fully blocked; cannot implement or test signing/notarization workflow
- **E4 E2E Release Simulation**: Blocked for macOS release path validation (Linux + manual notarization workaround still possible)
- **Release Quality**: Prebuilt macOS binaries will not carry notarization tickets, requiring users to manually allow execution (security friction)
- **User Experience**: macOS Homebrew tap users rebuilding from source will work; users downloading prebuilt bottles will encounter Gatekeeper warnings

---

## ✅ UNBLOCK CONDITIONS

To unblock E3, all of the following must be satisfied:

- [ ] **Apple Developer Program Enrollment**: Organization/maintainer enrolls or confirms active membership in Apple Developer Program
- [ ] **Developer ID Provisioning**: Obtain and securely store Developer ID Application certificate (`.p12` or keychain export)
- [ ] **Developer ID Password/Token**: Provision app-specific password or API token for notarytool authentication
- [ ] **Team ID Confirmation**: If using team account, confirm and document Team ID for API calls
- [ ] **CI Secrets Configuration**: Add the following secrets to GitHub repository:
  - `APPLE_DEVELOPER_ID_NAME` — "Developer ID Application: <Name>"
  - `APPLE_DEVELOPER_ID_PASSWORD` — secure app-specific password
  - `APPLE_NOTARY_TEAM_ID` — team identifier (if applicable)
  - `APPLE_CERTIFICATE_BASE64` — Base64-encoded certificate + private key
  - `APPLE_CERTIFICATE_PASSWORD` — keychain import password for certificate
- [ ] **GitHub Secrets Documentation**: Update `.github/SECRETS.md` with provisioning instructions and security best practices

---

## 🛠️ WORKAROUNDS CONSIDERED

### 1. Self-Signing Without Notarization
- **Approach**: Sign binaries with ad-hoc (self-generated) identity without Apple Developer ID
- **Limitation**: Users still see Gatekeeper warnings; no trust chain; less secure
- **Decision**: REJECTED — defeats purpose of E3; D4-MAC already documents full codesign/notarization pathway

### 2. Manual Notarization Post-Release
- **Approach**: Release unsigned binaries; maintainer notarizes manually outside CI
- **Limitation**: Adds manual overhead; breaks release automation goal (E2 emphasis on automation)
- **Decision**: REJECTED for E3 automation objective; acceptable as interim measure for E4 E2E testing

### 3. Homebrew Source Builds Only
- **Approach**: Ship formula that rebuilds from source on user machines (no prebuilt bottles)
- **Limitation**: Long install times; doesn't address prebuilt binary distribution need
- **Decision**: REJECTED — D4-MAC already ships arm64/x86_64 tarballs and bottle support

### 4. Third-Party Code Signing Service
- **Approach**: Use EV Code Signing certificate provider (not Apple Developer ID)
- **Limitation**: Different certificate type; not suitable for Apple notarization workflow
- **Decision**: REJECTED — Apple notarization requires Apple Developer ID specifically

---

## 📅 BLOCKER TIMELINE

| Date | Event |
|------|-------|
| 2025-11-15 | D4-MAC task completed; E3 flagged as blocker in archive follow-up notes |
| 2025-11-22 | **E3 formally marked BLOCKED** by BLOCK.md protocol; external dependency flagged |

---

## 🔄 NEXT STEPS WHEN UNBLOCKING

Once unblock conditions are met:

1. **Verify Credentials**
   - Confirm Developer ID certificate validity and password reset if needed
   - Test notarytool connectivity: `notarytool history --teamID <TEAM_ID> --apple-id <EMAIL> --password <PASSWORD>`

2. **Update GitHub Secrets**
   - Add all required secrets to repository settings
   - Verify secrets are not logged in CI (add to `GITHUB_TOKEN` exclusion rules if needed)

3. **Implement Signing/Notarization Workflow**
   - Update `.github/workflows/release.yml` to:
     - Import certificate from Base64-encoded secret
     - Sign macOS binaries: `codesign --sign <IDENTITY> --options runtime --timestamp <BINARY>`
     - Notarize: `notarytool submit <BINARY.zip> --wait --teamID <TEAM_ID>`
     - Staple ticket: `xcrun stapler staple <BINARY>`
   - Add conditional job gates: only run on tagged releases
   - Add logging of notarization status + submission ID for audit trail

4. **Test End-to-End**
   - Tag a test release in safe branch
   - Verify workflow passes through codesign/notarization stages
   - Download notarized binary on macOS and verify no Gatekeeper warnings
   - Invoke task E4 (E2E Release Simulation) to validate full pipeline

5. **Document & Archive**
   - Move INPROGRESS file to `DOCS/TASK_ARCHIVE/29_E3_SigningNotarization/`
   - Update workplan and todo.md to mark E3 as complete
   - Capture any lessons learned in archive notes

---

## 📞 ESCALATION & STAKEHOLDER COMMUNICATION

**Who to Contact**: Project maintainer / organization with Apple Developer Program access

**What to Request**:
- Confirm membership in Apple Developer Program (paid enrollment)
- Request Developer ID Application certificate provisioning (or self-service download from developer.apple.com)
- Request app-specific password or API token for notarytool authentication
- Confirm team ID if using organization account
- Agreement to add credentials to GitHub repository secrets

**Follow-Up Interval**:
- Check status weekly if E3 is critical path for release
- Re-escalate if no response after 1 week

---

## 📎 RELATED TASKS & CROSS-REFERENCES

| Task | Status | Notes |
|------|--------|-------|
| [E2 Homebrew Tap Automation](../TASK_ARCHIVE/28_E2_HomebrewTapPublishing/) | ✅ Complete | Enables automated formula updates; E3 required for prebuilt binary signing |
| [E4 E2E Release Simulation](../todo.md) | Pending | Depends on E3 (or manual workaround) to validate full macOS release path |
| [D4-MAC macOS Release Channels](../TASK_ARCHIVE/26_D4-MAC_MacReleaseChannels/) | ✅ Complete | Documents codesign/notarization guidance; E3 implements CI automation |
| [D4 Package Distribution](../TASK_ARCHIVE/24_D4_PackageDistributionRelease/) | ✅ Complete | Release workflow; E3 adds signing stage |
| [D3 Documentation](../TASK_ARCHIVE/23_D3_DocumentUsageTestingWorkflow/) | ✅ Complete | README includes codesign/notarization user guidance |

---

## 🎯 SUCCESS CRITERIA (FOR UNBLOCKING)

When E3 is unblocked and executed, success is demonstrated by:
- [ ] GitHub Actions secrets configured and validated (test connection succeeds)
- [ ] Release workflow includes codesign stage that runs on all tagged releases
- [ ] Release workflow includes notarization stage with await logic
- [ ] Signed and notarized macOS binary passes Gatekeeper check: `spctl -a -v <BINARY>` outputs **accepted**
- [ ] Test release downloaded from GitHub with notarization ticket stapled
- [ ] CI logs show successful notarization submission + approval
- [ ] E3 task archived under `DOCS/TASK_ARCHIVE/29_E3_SigningNotarization/`
- [ ] README updated with automated codesign/notarization documentation
- [ ] E4 E2E Release Simulation unblocked and ready to execute

---

**Last Updated**: 2025-11-22
**Blocking Since**: 2025-11-22 (0 days)
**Owner**: docc2context agent
**Reviewers**: Maintainer (Apple Developer access holder)
