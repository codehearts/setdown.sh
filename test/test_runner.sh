#!/usr/bin/env bash

# Runs the given test file, or all tests with no arguments

readonly TEST_DIR=$(dirname "$0")
readonly TEST_SH=$(basename "$0")

if [[ $# -eq 1 ]]; then
  cd "$TEST_DIR" || exit

  # Execute the given test file
  echo "Running $1:"

  # shellcheck source=/dev/null
  source "$1"
  # shellcheck source=/dev/null
  source "$TEST_DIR/../setdown.sh"
  # shellcheck source=/dev/null
  source "$TEST_DIR/stub/stub.sh"
  # shellcheck source=/dev/null
  source "$TEST_DIR/shunit2/shunit2"
elif [[ $# -eq 0 ]]; then
  # Execute tests in the same directory as this script
  find "$TEST_DIR" -maxdepth 1 -type f \
    -name 'test_*' -and -not -name "$TEST_SH" \
    -exec bash -c "$TEST_DIR/$TEST_SH \$1" _ {} \;
fi
