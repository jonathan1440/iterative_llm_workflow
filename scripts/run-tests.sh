#!/bin/bash
# Run tests and capture results for refactoring safety

set -e

MODE="$1"  # --baseline or --verify
TEST_CMD="${TEST_CMD:-pytest tests/}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BASELINE_FILE=".refactor-baseline-${TIMESTAMP}.txt"
RESULTS_FILE=".refactor-results-${TIMESTAMP}.txt"

if [ "$MODE" = "--baseline" ]; then
    echo "🧪 Running Pre-Refactor Tests (Baseline)"
    echo ""
    
    # Run tests and capture output
    if $TEST_CMD > "$BASELINE_FILE" 2>&1; then
        TEST_EXIT=0
    else
        TEST_EXIT=$?
    fi
    
    # Parse results (pytest format)
    if command -v pytest >/dev/null 2>&1; then
        PASSED=$(grep -oP '\d+(?= passed)' "$BASELINE_FILE" | tail -1 || echo "0")
        FAILED=$(grep -oP '\d+(?= failed)' "$BASELINE_FILE" | tail -1 || echo "0")
        TOTAL=$((PASSED + FAILED))
    else
        # Generic parsing for other test frameworks
        TOTAL=$(grep -c "test_" "$BASELINE_FILE" || echo "0")
        PASSED=$(grep -c "PASS\|OK\|✓" "$BASELINE_FILE" || echo "0")
        FAILED=$((TOTAL - PASSED))
    fi
    
    echo "════════════════════════════════════════════════════════════"
    cat "$BASELINE_FILE"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "$TOTAL tests ran"
    echo "$PASSED passed, $FAILED failed"
    echo ""
    
    # Store baseline
    echo "TOTAL=$TOTAL" > .refactor-baseline.env
    echo "PASSED=$PASSED" >> .refactor-baseline.env
    echo "FAILED=$FAILED" >> .refactor-baseline.env
    
    if [ "$FAILED" -gt 0 ]; then
        echo "⚠️  BASELINE FAILURES DETECTED"
        echo ""
        echo "Failed tests will be ignored in verification"
        echo "But new failures will indicate refactoring broke something"
    else
        echo "✅ All tests passing - good baseline"
    fi
    
    exit 0
    
elif [ "$MODE" = "--verify" ]; then
    echo "🧪 Running Post-Refactor Tests (Verification)"
    echo ""
    
    # Load baseline
    if [ ! -f ".refactor-baseline.env" ]; then
        echo "ERROR: No baseline found. Run with --baseline first"
        exit 1
    fi
    source .refactor-baseline.env
    
    # Run tests
    if $TEST_CMD > "$RESULTS_FILE" 2>&1; then
        TEST_EXIT=0
    else
        TEST_EXIT=$?
    fi
    
    # Parse results
    if command -v pytest >/dev/null 2>&1; then
        NEW_PASSED=$(grep -oP '\d+(?= passed)' "$RESULTS_FILE" | tail -1 || echo "0")
        NEW_FAILED=$(grep -oP '\d+(?= failed)' "$RESULTS_FILE" | tail -1 || echo "0")
        NEW_TOTAL=$((NEW_PASSED + NEW_FAILED))
    else
        NEW_TOTAL=$(grep -c "test_" "$RESULTS_FILE" || echo "0")
        NEW_PASSED=$(grep -c "PASS\|OK\|✓" "$RESULTS_FILE" || echo "0")
        NEW_FAILED=$((NEW_TOTAL - NEW_PASSED))
    fi
    
    echo "════════════════════════════════════════════════════════════"
    cat "$RESULTS_FILE"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Compare with baseline
    NEW_TESTS=$((NEW_TOTAL - TOTAL))
    REGRESSION=$((FAILED - NEW_FAILED))
    
    if [ "$REGRESSION" -lt 0 ]; then
        # More failures than baseline - bad!
        echo "❌ REFACTOR VERIFICATION FAILED"
        echo ""
        echo "Comparison with baseline:"
        echo "- Baseline: $PASSED passed, $FAILED failed ($TOTAL total)"
        echo "- Current:  $NEW_PASSED passed, $NEW_FAILED failed ($NEW_TOTAL total)"
        echo "- New tests: $NEW_TESTS"
        echo "- REGRESSIONS: $((-REGRESSION)) new failures ❌"
        echo ""
        echo "⚠️  Refactoring introduced failures. Consider rollback."
        exit 1
    else
        echo "✅ REFACTOR VERIFICATION PASSED"
        echo ""
        echo "Comparison with baseline:"
        echo "- Baseline: $PASSED passed, $FAILED failed ($TOTAL total)"
        echo "- Current:  $NEW_PASSED passed, $NEW_FAILED failed ($NEW_TOTAL total)"
        echo "- New tests: $NEW_TESTS"
        echo "- Regressions: 0"
        echo ""
        echo "**Result**: Refactor successful ✓"
        exit 0
    fi
else
    echo "ERROR: Invalid mode. Use --baseline or --verify"
    exit 1
fi
