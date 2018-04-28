#!/usr/bin/env bash

test_link_does_not_exist() {
  touch "$FILE_1"

  createSpy setdown_getconsent
  createSpy -r 0 sudo # ln succeeds

  assertCommandTrue "Returned false when ln was successful" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertCalledOnceWith_ "Link was created without calling sudo" \
    sudo ln -s "$FILE_1" "$FILE_2"

  assertNeverCalled "Prompt was displayed when link was created successfully" \
    setdown_getconsent

  # Call arguments to sudo to ensure they behave as desired
  ln -s "$FILE_1" "$FILE_2"

  assertEquals "Link was created to wrong file" \
    "$FILE_1" "$(readlink "$FILE_2")"
}

test_link_already_exists_to_same_file() {
  touch "$FILE_1"
  ln -s "$FILE_1" "$FILE_2"

  createSpy setdown_getconsent
  createSpy -r 1 sudo # ln fails

  assertCommandTrue "Returned false when link to file already existed" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was changed when it should have been left alone" \
    "$FILE_1" "$(readlink "$FILE_2")"

  assertCalledOnceWith_ "Link was created without calling sudo" \
    sudo ln -s "$FILE_1" "$FILE_2"

  assertNeverCalled "Prompt displayed when link should have been left alone" \
    setdown_getconsent
}

test_link_already_exists_to_different_file_user_forces() {
  # Link file_2 to file_3, then attempt to link file_2 to file_1
  touch "$FILE_1", "$FILE_3"
  ln -s "$FILE_3" "$FILE_2"

  createSpy -r 0 setdown_getconsent # User consents
  createSpy -r 1 -r 0 sudo # ln fails, ln -f succeeds

  assertCommandTrue "Returned false when ln failed and user forced link" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertCallCount "Sudo was called too many times" \
    sudo 2
  assertCalledWith_ "Link was created without calling sudo" \
    sudo ln -s "$FILE_1" "$FILE_2"
  assertCalledWith_ "Link was forcefully created without calling sudo" \
    sudo ln -sf "$FILE_1" "$FILE_2"

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't link $FILE_1 to $FILE_2, try forcing?"

  # Call arguments to sudo to ensure they behave as desired
  ln -sf "$FILE_1" "$FILE_2"

  assertEquals "Link was not forcefully overwritten" \
    "$FILE_1" "$(readlink "$FILE_2")"
}

test_link_already_exists_to_different_file_user_does_not_force() {
  # Link file_2 to file_3, then attempt to link file_2 to file_1
  touch "$FILE_1", "$FILE_3"
  ln -s "$FILE_3" "$FILE_2"

  createSpy -r 1 setdown_getconsent # User does not consent
  createSpy -r 1 sudo # ln fails

  assertCommandFalse "Returned true when ln failed and user didn't force" \
    setdown_sudo_link "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Link was overwritten when it should not have been" \
    "$FILE_3" "$(readlink "$FILE_2")"

  assertCalledOnceWith_ "Link was created without calling sudo" \
    sudo ln -s "$FILE_1" "$FILE_2"

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't link $FILE_1 to $FILE_2, try forcing?"
}
