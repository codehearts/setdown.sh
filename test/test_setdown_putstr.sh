#!/bin/sh

test_display_message() {
  createSpy -r 0 dialog

  assertCommandTrue "Returned false when user pressed ok button" \
    setdown_putstr "Test message"
  assertCommandOutputNull

  assertCalledOnceWith_ "dialog was not called to display text" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --infobox "Test message" 12 50
}
