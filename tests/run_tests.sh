#!/bin/bash

# Test runner for all LuaJIT tests
# Usage: ./run_tests.sh [luajit_path]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Find the LuaJIT binary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Initialize submodule if needed
if [ -d "$SCRIPT_DIR/luajit2-test-suite" ]; then
    if [ ! -f "$SCRIPT_DIR/luajit2-test-suite/run-tests" ]; then
        echo -e "${BLUE}Initializing luajit2-test-suite submodule...${NC}"
        cd "$PROJECT_ROOT"
        git submodule update --init --recursive tests/luajit2-test-suite
        cd "$SCRIPT_DIR"
        echo ""
    fi
fi

# Check for custom LuaJIT path or use default
if [ -n "$1" ]; then
    LUAJIT="$1"
else
    LUAJIT="$PROJECT_ROOT/bin/luajit"
fi

if [ ! -x "$LUAJIT" ]; then
    echo -e "${RED}Error: LuaJIT binary not found at $LUAJIT${NC}"
    echo "Please build LuaJIT first by running 'make' in the project root"
    echo "Or specify the path: ./run_tests.sh /path/to/luajit"
    exit 1
fi

echo "Using LuaJIT: $LUAJIT"
echo "LuaJIT version:"
$LUAJIT -v
echo ""

# Counter for passed/failed tests
PASSED=0
FAILED=0
TOTAL=0

# Function to run a single test file
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file")
    
    TOTAL=$((TOTAL + 1))
    
    echo -n "Running $test_name... "
    
    if $LUAJIT "$test_file" > /tmp/test_output_$$.txt 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
        # Show test output (filtered to reduce noise)
        cat /tmp/test_output_$$.txt | grep -v "^[0-9.]*$" | sed 's/^/  /' || true
    else
        echo -e "${RED}FAILED${NC}"
        FAILED=$((FAILED + 1))
        echo "Error output:"
        cat /tmp/test_output_$$.txt | sed 's/^/  /'
    fi
    
    rm -f /tmp/test_output_$$.txt
    echo ""
}

# Run all test files
echo "========================================"
echo "Running All Tests"
echo "========================================"
echo ""

# Automatically find all test_*.lua files in the tests directory
for test_file in "$SCRIPT_DIR"/test_*.lua; do
    if [ -f "$test_file" ]; then
        run_test "$test_file"
    fi
done

# Run luajit2-test-suite if available
if [ -d "$SCRIPT_DIR/luajit2-test-suite" ] && [ -f "$SCRIPT_DIR/luajit2-test-suite/run-tests" ]; then
    echo "========================================"
    echo "Running luajit2-test-suite"
    echo "========================================"
    echo ""
    
    cd "$SCRIPT_DIR/luajit2-test-suite"
    if ./run-tests "$PROJECT_ROOT" "$LUAJIT" > /tmp/luajit2_test_suite_$$.txt 2>&1; then
        echo -e "${GREEN}luajit2-test-suite PASSED${NC}"
        PASSED=$((PASSED + 1))
        # Show summary line
        tail -1 /tmp/luajit2_test_suite_$$.txt
    else
        echo -e "${RED}luajit2-test-suite FAILED${NC}"
        FAILED=$((FAILED + 1))
        echo "Error output:"
        tail -20 /tmp/luajit2_test_suite_$$.txt | sed 's/^/  /'
    fi
    rm -f /tmp/luajit2_test_suite_$$.txt
    TOTAL=$((TOTAL + 1))
    cd "$SCRIPT_DIR"
    echo ""
fi

# Print summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total tests: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
