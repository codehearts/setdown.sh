#!/bin/sh

# Existing command returns `true` with no output
test_command_exists() {
  assertCommandTrue "Returned false for installed command" \
    setdown_hascmd cat
  assertCommandOutputNull
}

# Non-existent command returns `false` with no output
test_command_does_not_exist() {
  assertCommandFalse "Returned true for missing command" \
    setdown_hascmd doesnotexist
  assertCommandOutputNull
}
