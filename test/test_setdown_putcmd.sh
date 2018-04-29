#!/bin/sh

test_command_succeeds() {
  createSpy -r 0 myCommand
  createSpy -r 0 dialog

  assertCommandTrue "Returned false when command returned true" \
    setdown_putcmd myCommand arg1 arg2
  assertCommandOutputNull

  assertCalledOnceWith_ "Command was not called with given arguments" \
    myCommand arg1 arg2

  assertCalledOnceWith_ "dialog was not called to obtain user input" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --progressbox 24 80
}

test_command_fails() {
  createSpy -r 1 myCommand
  createSpy -r 0 dialog

  assertCommandFalse "Returned true when command returned false" \
    setdown_putcmd myCommand arg1 arg2
  assertCommandOutputNull

  assertCalledOnceWith_ "Command was not called with given arguments" \
    myCommand arg1 arg2

  assertCalledOnceWith_ "dialog was not called to obtain user input" \
    dialog --scrollbar --no-lines --no-shadow --output-fd 1 \
      --progressbox 24 80
}
