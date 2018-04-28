#!/usr/bin/env bash

test_user_consents() {
  createSpy -r 0 dialog

  assertCommandTrue "Returned false when user consented" \
    setdown_getconsent "Test Question"
  assertCommandOutputNull

  assertCalledOnceWith_ "Dialog was invoked with wrong arguments" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --yesno "Test Question" 12 50
}

test_user_does_not_consent() {
  createSpy -r 1 dialog

  assertCommandFalse "Returned true when user did not consent" \
    setdown_getconsent "Test Question"
  assertCommandOutputNull

  assertCalledOnceWith_ "Dialog was invoked with wrong arguments" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --yesno "Test Question" 12 50
}
