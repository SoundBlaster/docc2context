## Summary
- add a helper script to compress the Swift build directory into a reusable cache archive stored via Git LFS
- improve input detection errors to cover invalid DocC bundles or archives, including restoring directory-specific guidance for file inputs and providing clear archive extraction guidance
- extend CLI and detector tests to validate archive messaging, rejection of non-DocC files, and directory validation messaging

## Testing
- swift test
