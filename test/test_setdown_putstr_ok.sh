#!/usr/bin/env bash

test_display_message_with_ok_button() {
  createSpy -r 0 dialog

  assertCommandTrue "Returned false when user pressed ok button" \
    setdown_putstr_ok "Test message"
  assertCommandOutputNull

  assertCalledOnceWith_ "dialog was not called to display text w/ ok button" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --msgbox "Test message" 12 50
}
