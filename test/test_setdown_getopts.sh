#!/usr/bin/env bash

test_with_no_options() {
  local options=()

  stub dialog

  assertCommandTrue "Returned false when no options were given" \
    setdown_getopts "Test Title" options
  assertCommandOutputEquals "()"

  assertEquals "Checklist was displayed with no options" \
    "0" "$(stub_called_times 'dialog')"

  restore dialog
}

test_with_options() {
  # shellcheck disable=SC2034
  local options=('option 1' off 'option 2' on)

  stub_and_eval dialog "echo -n '\"option 1\" \"option 2\"'"

  assertCommandTrue "Returned false when options were given" \
    setdown_getopts "Test Title" options
  assertCommandOutputEquals '("option 1" "option 2")'

  assertEquals "Checklist was not displayed with options" \
    "1" "$(stub_called_times 'dialog')"
  assertTrue "Dialog was invoked with wrong arguments" \
    "stub_called_with dialog --scrollbar --no-lines --no-shadow --output-fd 1 --no-items --checklist Test Title 24 70 16 option 1 off option 2 on"

  restore dialog
}
