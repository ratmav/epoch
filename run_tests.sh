#!/bin/bash

# Sequential test runner to replace plenary.test_harness
# Runs each test file individually to avoid hanging issues

set -e

TEST_DIR="./tests"
PASSED=0
FAILED=0
TOTAL=0

echo "🧪 Finding test files..."

# Find all test files, excluding helpers and fixtures
TEST_FILES=$(find "$TEST_DIR" -name "*_spec.lua" -type f | grep -v "/fixtures/" | grep -v "/helpers/" | grep -v "/scripts/" | sort)

echo "📋 Found $(echo "$TEST_FILES" | wc -l) test files"
echo "========================================"

START_TIME=$(date +%s)

for TEST_FILE in $TEST_FILES; do
    echo "🔍 Running: $TEST_FILE"
    
    if NVIM_INSTALL_MODE=1 nvim --headless \
        -c "lua package.path='$(pwd)/lua/?.lua;'..package.path" \
        -c "lua require('plenary.test_harness').test_directory('$TEST_FILE', {minimal_init = './tests/minimal_init.lua'})" \
        -c "quit" 2>&1 | grep -q "Success:"; then
        echo "✅ PASSED"
        PASSED=$((PASSED + 1))
    else
        echo "❌ FAILED"
        FAILED=$((FAILED + 1))
    fi
    
    TOTAL=$((TOTAL + 1))
    echo ""
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "========================================"
echo "📊 Results: $PASSED/$TOTAL files passed"
if [ $FAILED -gt 0 ]; then
    echo "❌ $FAILED files failed"
else
    echo "✅ All tests passed!"
fi
echo "⏱️  Duration: ${DURATION}s"

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi