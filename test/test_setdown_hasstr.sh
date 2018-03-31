#!/usr/bin/env bash

# Create a unique file for each test to redirect command output to
oneTimeSetUp() {
  readonly COMMAND_OUTPUT_FILE=$(mktemp)
}

# Clears the command output file after each test
tearDown() {
  : > "$COMMAND_OUTPUT_FILE"
}



# Member of array returns `true` with no output
test_string_is_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  setdown_hasstr fruits 'cherry' > "$COMMAND_OUTPUT_FILE" 2>&1

  assertTrue "Returned false for member" "$?"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}

# Non-member returns `false` with no output
test_string_is_not_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  setdown_hasstr fruits 'celery' > "$COMMAND_OUTPUT_FILE" 2>&1

  assertFalse "Returned true for non-member" "$?"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}
