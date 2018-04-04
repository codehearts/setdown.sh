#!/usr/bin/env bash

test_link_does_not_exist() {
  touch "$FILE_1"

  stub setdown_getconsent
  stub_and_eval sudo "\$@" # Bypass actually running sudo

  assertCommandTrue "Returned false when ln was successful" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was created to wrong file" \
    "$FILE_1" "$(readlink "$FILE_2")"
  assertEquals "Sudo was called too many times" \
    "1" "$(stub_called_times 'sudo')"
  assertTrue "Link was created without calling sudo" \
    "stub_called_with_exactly_times sudo 1 ln -s $FILE_1 $FILE_2"
  assertFalse "Prompt was displayed when link was created successfully" \
    "stub_called setdown_getconsent"

  restore setdown_getconsent
  restore sudo
}

test_link_already_exists_to_same_file() {
  touch "$FILE_1"
  ln -s "$FILE_1" "$FILE_2"

  stub setdown_getconsent
  stub_and_eval sudo "\$@" # Bypass actually running sudo

  assertCommandTrue "Returned false when link to file already existed" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was changed when it should have been left alone" \
    "$FILE_1" "$(readlink "$FILE_2")"
  assertEquals "Sudo was called too many times" \
    "1" "$(stub_called_times 'sudo')"
  assertTrue "Link was created without calling sudo" \
    "stub_called_with_exactly_times sudo 1 ln -s $FILE_1 $FILE_2"
  assertFalse "Prompt was displayed when link should have been left alone" \
    "stub_called setdown_getconsent"

  restore setdown_getconsent
  restore sudo
}

test_link_already_exists_to_different_file_user_forces() {
  # Link file_2 to file_3, then attempt to link file_2 to file_1
  touch "$FILE_1", "$FILE_3"
  ln -s "$FILE_3" "$FILE_2"

  stub_and_eval setdown_getconsent "true"
  stub_and_eval sudo "\$@" # Bypass actually running sudo

  assertCommandTrue "Returned false when ln failed and user forced link" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was not forcefully overwritten" \
    "$FILE_1" "$(readlink "$FILE_2")"
  assertEquals "Sudo was called too many times" \
    "2" "$(stub_called_times 'sudo')"
  assertEquals "Prompt was not displayed to force linking" \
    "1" "$(stub_called_times 'setdown_getconsent')"
  assertTrue "Link was created without calling sudo" \
    "stub_called_with_exactly_times sudo 1 ln -s $FILE_1 $FILE_2"
  assertTrue "Link was forcefully created without calling sudo" \
    "stub_called_with_exactly_times sudo 1 ln -sf $FILE_1 $FILE_2"
  assertTrue "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link $FILE_1 to $FILE_2, try forcing?\""

  restore setdown_getconsent
  restore sudo
}

test_link_already_exists_to_different_file_user_does_not_force() {
  # Link file_2 to file_3, then attempt to link file_2 to file_1
  touch "$FILE_1", "$FILE_3"
  ln -s "$FILE_3" "$FILE_2"

  stub_and_eval setdown_getconsent "false"
  stub_and_eval sudo "\$@" # Bypass actually running sudo

  assertCommandFalse "Returned true when ln failed and user didn't force" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was overwritten when it should not have been" \
    "$FILE_3" "$(readlink "$FILE_2")"
  assertEquals "Sudo was called too many times" \
    "1" "$(stub_called_times 'sudo')"
  assertEquals "Prompt was not displayed to force linking" \
    "1" "$(stub_called_times 'setdown_getconsent')"
  assertTrue "Link was created without calling sudo" \
    "stub_called_with_exactly_times sudo 1 ln -s $FILE_1 $FILE_2"
  assertTrue "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link $FILE_1 to $FILE_2, try forcing?\""

  restore setdown_getconsent
  restore sudo
}
