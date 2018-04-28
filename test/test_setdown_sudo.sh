#!/usr/bin/env bash

test_sudo_already_primed() {
  createSpy -r 0 sudo # Cache already primed
  createSpy -r 0 setdown_getpw

  assertCommandTrue "Returned false when sudo was already primed" \
    setdown_sudo "Enter credentials:"
  assertCommandOutputNull

  assertNeverCalled "setdown_getpw was called when unneeded" \
    setdown_getpw

  assertCallCount "sudo was called too many times" \
    sudo 1
  assertCalledWith_ "Sudo was not called once in non-interactive mode" \
    sudo -vn
}

test_sudo_user_aborts() {
  # Sudo cache not already primed
  createSpy -r 1 -e 'sudo: a password is required' sudo
  createSpy -r 1 setdown_getpw # User aborts password entry

  assertCommandFalse "Returned true when user aborted initial pw entry" \
    setdown_sudo "Enter credentials:"
  assertCommandOutputNull

  assertCallCount "setdown_getpw was called too many times" \
    setdown_getpw 1
  assertCalledWith_ "setdown_getpw was called with incorrect title" \
    setdown_getpw "Enter credentials:"

  assertCallCount "sudo was called too many times" \
    sudo 1
  assertCalledWith_ "sudo was not called in non-interactive mode" \
    sudo -vn
}

test_sudo_user_enters_correct_password() {
  # Sudo cache not already primed
  createSpy -r 1 -r 0 -e 'sudo: a password is required' sudo
  createSpy -r 0 -o 'testpass' setdown_getpw

  assertCommandTrue "Returned false when user entered correct password" \
    setdown_sudo "Enter credentials:"
  assertCommandOutputNull

  assertCallCount "setdown_getpw was called too many times" \
    setdown_getpw 1
  assertCalledWith_ "setdown_getpw was called with incorrect title" \
    setdown_getpw "Enter credentials:"

  assertCallCount "sudo was called too many times" \
    sudo 2
  assertCalledWith_ "sudo was not called in non-interactive mode" \
    sudo -vn
  assertCalledWith_ "sudo was not called with password via stdin" \
    sudo -Svp ''
}

test_sudo_user_enters_incorrect_password_once() {
  # Sudo cache not already primed, invalid password once
  createSpy -r 1 -r 1 -r 0 -e 'sudo: a password is required' sudo
  createSpy -r 0 -o 'testpass' setdown_getpw

  assertCommandTrue "Returned false when user entered correct password" \
    setdown_sudo "Enter credentials:"
  assertCommandOutputNull

  assertCallCount "setdown_getpw was called too many times" \
    setdown_getpw 2
  assertCalledWith_ "setdown_getpw was called with incorrect title" \
    setdown_getpw "Enter credentials:"
  assertCalledWith_ "setdown_getpw did not display incorrect pw message" \
    setdown_getpw "Incorrect password, try again:"

  assertCallCount "sudo was called too many times" \
    sudo 3
  assertCalledWith_ "sudo was not called in non-interactive mode" \
    sudo -vn
  assertCalledWith_ "sudo was not called with password via stdin" \
    sudo -Svp ''
}

test_sudo_user_enters_incorrect_password_twice() {
  # Sudo cache not already primed, invalid password twice
  createSpy -r 1 -r 1 -r 1 -r 0 -e 'sudo: a password is required' sudo
  createSpy -r 0 -o 'testpass' setdown_getpw

  assertCommandTrue "Returned false when user entered correct password" \
    setdown_sudo "Enter credentials:"
  assertCommandOutputNull

  assertCallCount "setdown_getpw was called too many times" \
    setdown_getpw 3
  assertCalledWith_ "setdown_getpw was called with incorrect title" \
    setdown_getpw "Enter credentials:"
  assertCalledWith_ "setdown_getpw did not display incorrect pw message" \
    setdown_getpw "Incorrect password, try again:"

  assertCallCount "sudo was called too many times" \
    sudo 4
  assertCalledWith_ "sudo was not called in non-interactive mode" \
    sudo -vn
  assertCalledWith_ "sudo was not called with password via stdin" \
    sudo -Svp ''
}
