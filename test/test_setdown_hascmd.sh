#!/usr/bin/env bash

# Create a unique file for each test to redirect command output to
oneTimeSetUp() {
  readonly COMMAND_OUTPUT_FILE=$(mktemp)
}

# Clears the command output file after each test
tearDown() {
  : > "$COMMAND_OUTPUT_FILE"
}



# Existing command returns `true` with no output
test_command_exists() {
  setdown_hascmd cat > "$COMMAND_OUTPUT_FILE" 2>&1

  assertTrue "Returned false for installed command" "$?"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}

# Non-existent command returns `false` with no output
test_command_does_not_exist() {
  setdown_hascmd doesnotexist > "$COMMAND_OUTPUT_FILE" 2>&1

  assertFalse "Returned true for missing command" "$?"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}
