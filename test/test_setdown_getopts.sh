#!/bin/sh

test_with_no_options() {
  local options=()

  createSpy dialog

  assertCommandTrue "Returned false when no options were given" \
    setdown_getopts "Test Title" options
  assertCommandOutputEquals "()"

  assertNeverCalled "Checklist was displayed with no options" \
    dialog
}

test_with_options() {
  # shellcheck disable=SC2034
  local options=('option 1' off 'option 2' on)

  createSpy -r 0 -o '"option 1" "option 2"' dialog

  assertCommandTrue "Returned false when options were given" \
    setdown_getopts "Test Title" options
  assertCommandOutputEquals '("option 1" "option 2")'

  assertCalledOnceWith_ "Dialog was invoked with wrong arguments" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --no-items --checklist "Test Title" 24 70 16 "option 1" off "option 2" on
}
