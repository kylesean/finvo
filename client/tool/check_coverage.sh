#!/usr/bin/env bash
# Client Test Coverage Check Script

set -euo pipefail

echo "=== Running Flutter Tests with Coverage ==="
flutter test --coverage

if command -v lcov >/dev/null 2>&1; then
    echo "=== Coverage Summary ==="
    lcov --summary coverage/lcov.info
else
    echo "Coverage data saved to coverage/lcov.info"
fi
