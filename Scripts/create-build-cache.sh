#!/bin/bash
#
# Create build cache for Hyperprompt project
#
# This script creates a compressed archive of the .build directory
# to speed up subsequent builds (from 82s to 5-10s).
#
# Usage:
#   ./create-build-cache.sh [cache-name]
#
# Example:
#   ./create-build-cache.sh swift-build-cache-linux-x86_64
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default cache name
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
CACHE_NAME="${1:-swift-build-cache-${OS}-${ARCH}}"
CACHE_DIR="${BUILD_CACHE_DIR:-.build-cache}"
BUILD_DIR=".build"

echo -e "${GREEN}Creating build cache...${NC}"
echo "  Cache name: ${CACHE_NAME}.tar.gz"
echo "  Build directory: ${BUILD_DIR}"
echo "  Cache directory: ${CACHE_DIR}"

# Check if .build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}Error: ${BUILD_DIR} directory not found${NC}"
    echo "Run 'swift build' first to create build artifacts"
    exit 1
fi

# Get build directory size
BUILD_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)
echo "  Build directory size: ${BUILD_SIZE}"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Create cache archive
echo -e "${YELLOW}Compressing...${NC}"
tar -czf "${CACHE_DIR}/${CACHE_NAME}.tar.gz" "$BUILD_DIR" 2>&1

# Get cache file size
CACHE_SIZE=$(du -sh "${CACHE_DIR}/${CACHE_NAME}.tar.gz" | cut -f1)
echo -e "${GREEN}Cache created successfully!${NC}"
echo "  Cache file: ${CACHE_DIR}/${CACHE_NAME}.tar.gz"
echo "  Cache size: ${CACHE_SIZE}"
echo ""
echo "To use this cache:"
echo "  1. Copy ${CACHE_DIR}/${CACHE_NAME}.tar.gz to new environment"
echo "  2. Run: tar -xzf ${CACHE_DIR}/${CACHE_NAME}.tar.gz"
echo "  3. Run: swift build (will use cached dependencies)"
echo ""
echo "Expected speedup: 82s → 5-10s (8-16x faster)"
