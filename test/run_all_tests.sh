#!/bin/sh

# Passes all scripts in test/ beginning with test_ to run_test.sh
# If USE_KCOV is set externally, tests will be run through kcov
# Exits with status 0 only if no tests failed
#

# Change into the project root directory
cd "$(dirname "$0")/.." || exit

# Set the test runner, and use kcov if USE_KCOV is set true
TEST_RUNNER='test/run_test.sh'
[ "$USE_KCOV" ] && \
  TEST_RUNNER="kcov ./coverage --exclude-path=test/ $TEST_RUNNER"

# Find all scripts in test/ beginning with test_, and pass them to run_test.sh
# If any test fails, the status variable will be set accordingly
status=0
for TEST_FILE in test/test_*; do
  bash -c "$TEST_RUNNER $TEST_FILE" || status=$?
done

# Exits with 0 only if all tests passed
exit $status
