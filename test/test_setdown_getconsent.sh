#!/usr/bin/env bash

test_user_consents() {
  stub_and_eval dialog 'return 0'

  assertCommandTrue "Returned false when user consented" \
    setdown_getconsent "Test Question"
  assertCommandOutputNull

  assertEquals "Dialog was not invoked to ask consent" \
    "1" "$(stub_called_times 'dialog')"
  assertTrue "Dialog was invoked with wrong arguments" \
    "stub_called_with dialog --scrollbar --no-lines --no-shadow --output-fd 1 --yesno Test Question 12 50"

  restore dialog
}

test_user_does_not_consent() {
  stub_and_eval dialog 'return 1'

  assertCommandFalse "Returned true when user did not consent" \
    setdown_getconsent "Test Question"
  assertCommandOutputNull

  assertEquals "Dialog was not invoked to ask consent" \
    "1" "$(stub_called_times 'dialog')"
  assertTrue "Dialog was invoked with wrong arguments" \
    "stub_called_with dialog --scrollbar --no-lines --no-shadow --output-fd 1 --yesno Test Question 12 50"

  restore dialog
}
