#!/bin/bash

# Coverage Script for Photo Manager App
# This script runs tests with coverage and generates HTML reports
#
# Usage:
#   ./coverage.sh              # Run tests and generate coverage
#   ./coverage.sh --open       # Generate and open HTML report
#   ./coverage.sh --check      # Check if coverage meets threshold

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COVERAGE_THRESHOLD=80
COVERAGE_DIR="coverage"
HTML_DIR="${COVERAGE_DIR}/html"
LCOV_FILE="${COVERAGE_DIR}/lcov.info"
FILTERED_LCOV="${COVERAGE_DIR}/lcov_filtered.info"

echo -e "${GREEN}🧪 Photo Manager App - Test Coverage${NC}"
echo "========================================"
echo ""

# Clean previous coverage data
echo "🧹 Cleaning previous coverage data..."
rm -rf ${COVERAGE_DIR}
mkdir -p ${COVERAGE_DIR}

# Run tests with coverage
echo ""
echo "🚀 Running tests with coverage..."
flutter test --coverage --coverage-path=${LCOV_FILE}

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Tests failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Tests passed!${NC}"

# Filter out generated files and unnecessary files from coverage
echo ""
echo "🔍 Filtering coverage data..."

# Exclude patterns:
# - Generated files (*.g.dart, *.freezed.dart)
# - Main entry point (main.dart)
# - Test files
# - Generated localization files (app_localizations*.dart)

lcov --remove ${LCOV_FILE} \
    'lib/main.dart' \
    '**/core/**' \
    '**/*.g.dart' \
    '**/*.freezed.dart' \
    '**/l10n/app_localizations*.dart' \
    '**/test/**' \
    --ignore-errors unused \
    --output-file ${FILTERED_LCOV}

# Generate HTML report
echo ""
echo "📊 Generating HTML coverage report..."
genhtml ${FILTERED_LCOV} \
    --output-directory ${HTML_DIR} \
    --title "Photo Manager App - Test Coverage" \
    --show-details \
    --legend \
    --quiet 2>/dev/null || {
        echo -e "${YELLOW}⚠️  genhtml not found. Install with: brew install lcov (macOS) or apt-get install lcov (Linux)${NC}"
        echo "Skipping HTML report generation."
    }

# Extract coverage percentage
COVERAGE_PERCENT=$(lcov --summary ${FILTERED_LCOV} 2>&1 | grep "lines......:" | awk '{print $2}' | sed 's/%//')

echo ""
echo "========================================"
echo -e "Coverage: ${GREEN}${COVERAGE_PERCENT}%${NC}"
echo "Coverage file: ${LCOV_FILE}"
echo "HTML report: ${HTML_DIR}/index.html"
echo "========================================"

# Check coverage threshold
if [ "$1" == "--check" ]; then
    echo ""
    if (( $(echo "$COVERAGE_PERCENT >= $COVERAGE_THRESHOLD" | bc -l) )); then
        echo -e "${GREEN}✅ Coverage meets threshold (>= ${COVERAGE_THRESHOLD}%)${NC}"
        exit 0
    else
        echo -e "${RED}❌ Coverage below threshold (< ${COVERAGE_THRESHOLD}%)${NC}"
        echo -e "${YELLOW}Current: ${COVERAGE_PERCENT}% | Required: ${COVERAGE_THRESHOLD}%${NC}"
        exit 1
    fi
fi

# Open HTML report
if [ "$1" == "--open" ]; then
    echo ""
    echo "🌐 Opening coverage report in browser..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open ${HTML_DIR}/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open ${HTML_DIR}/index.html 2>/dev/null || {
            echo "Please open ${HTML_DIR}/index.html manually"
        }
    else
        echo "Please open ${HTML_DIR}/index.html manually"
    fi
fi

echo ""
echo -e "${GREEN}✨ Coverage analysis complete!${NC}"
