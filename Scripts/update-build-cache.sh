#!/bin/bash
#
# Update build cache for Hyperprompt project
#
# This script rebuilds the Swift project and regenerates the cache archive
# using the same defaults as create-build-cache.sh.
#
# Usage:
#   ./update-build-cache.sh [cache-name]
#
# Example:
#   ./update-build-cache.sh swift-build-cache-linux-x86_64
#
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
CACHE_NAME="${1:-swift-build-cache-${OS}-${ARCH}}"

if ! command -v swift >/dev/null 2>&1; then
  echo -e "${RED}Error: swift not found in PATH${NC}"
  exit 1
fi

echo -e "${GREEN}Updating build cache...${NC}"
echo "  Cache name: ${CACHE_NAME}.tar.gz"

BUILD_FLAGS=${SWIFT_BUILD_FLAGS:-}
if [ -n "$BUILD_FLAGS" ]; then
  echo "  Swift build flags: ${BUILD_FLAGS}"
fi

echo -e "${YELLOW}Rebuilding .build directory...${NC}"
swift build ${BUILD_FLAGS}

echo -e "${YELLOW}Repacking cache archive...${NC}"
./Scripts/create-build-cache.sh "$CACHE_NAME"

echo -e "${GREEN}Cache update complete.${NC}"
