#!/usr/bin/env bash

test_password_entered() {
  createSpy -r 0 -o "testpass" dialog # User entered "testpass"

  assertCommandTrue "Returned false when user entered password" \
    setdown_getpw "Enter credentials:"
  assertCommandOutputEquals "testpass"

  assertCalledOnceWith_ "dialog was not called to obtain credentials" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --passwordbox "Enter credentials:" 12 50
}

test_password_entry_aborted() {
  createSpy -r 1 dialog # User aborted password entry

  assertCommandFalse "Returned true when user aborted password entry" \
    setdown_getpw "Enter credentials:"
  assertCommandOutputNull

  assertCalledOnceWith_ "dialog was not called to obtain credentials" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --passwordbox "Enter credentials:" 12 50
}
