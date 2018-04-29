#!/bin/sh

test_text_entered_without_default() {
  createSpy -r 0 -o "testname" dialog # User entered "testname"

  assertCommandTrue "Returned false when user entered text" \
    setdown_getstr "Enter name:"
  assertCommandOutputEquals "testname"

  assertCalledOnceWith_ "dialog was not called to obtain user input" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --inputbox "Enter name:" 12 50 ""
}

test_text_entered_with_default() {
  createSpy -r 0 -o "testname" dialog # User entered "testname"

  assertCommandTrue "Returned false when user entered text w/ default value" \
    setdown_getstr "Enter name:" "Default"
  assertCommandOutputEquals "testname"

  assertCalledOnceWith_ "dialog not called to get input with default value" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --inputbox "Enter name:" 12 50 "Default"
}

test_text_entery_aborted() {
  createSpy -r 1 dialog # User aborted text entry

  assertCommandFalse "Returned true when user aborted text entry" \
    setdown_getstr "Enter name:"
  assertCommandOutputNull

  assertCalledOnceWith_ "dialog was not called to obtain user input" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --inputbox "Enter name:" 12 50 ""
}
