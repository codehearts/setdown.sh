#!/usr/bin/env bash

test_copy_file_destination_does_not_exist() {
  touch "$FILE_1"

  createSpy setdown_getconsent

  assertCommandTrue "Returned false when file was successfully copied" \
    setdown_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertTrue "Copy destination does not exist" \
    "[ -e $FILE_2 ]"

  assertNeverCalled "Prompt displayed when copy was performed successfully" \
    setdown_getconsent
}

test_copy_file_destination_is_same_file() {
  # Ensure file_1 and file_2 exist with the same contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 1.' > "$FILE_2"

  createSpy setdown_getconsent

  assertCommandTrue "Returned false when destination was already same file" \
    setdown_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Copy destination does not exist with same contents" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"

  assertNeverCalled "Prompt was displayed when copy was unneeded" \
    setdown_getconsent
}

test_copy_file_destination_is_different_file_user_forces() {
  # Ensure file_1 and file_2 exist with different contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 2.' > "$FILE_2"

  createSpy -r 0 setdown_getconsent # User consents

  assertCommandTrue "Returned false when user forced copy" \
    setdown_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Copy destination was not forcefully overwritten" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"

  assertCallCount "Prompt was not displayed to force linking" \
    setdown_getconsent 1
  assertCalledWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $FILE_1 to $FILE_2, try forcing?"
}

test_copy_file_destination_is_different_file_user_does_not_force() {
  # Ensure file_1 and file_2 exist with different contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 2.' > "$FILE_2"

  createSpy -r 1 setdown_getconsent # User does not consent

  assertCommandFalse "Returned true when dest exists and user didn't force" \
    setdown_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertNotEquals "Copy destination was overwritten without consent" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"

  assertCallCount "Prompt was not displayed to force linking" \
    setdown_getconsent 1
  assertCalledWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $FILE_1 to $FILE_2, try forcing?"
}

test_copy_directory_destination_does_not_exist() {
  mkdir "$DIR_1"

  createSpy setdown_getconsent

  assertCommandTrue "Returned false when directory was successfully copied" \
    setdown_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertTrue "Copy destination does not exist" \
    "[ -e $DIR_2 ]"

  assertNeverCalled "Prompt displayed when copy was performed successfully" \
    setdown_getconsent
}

test_copy_directory_destination_exists_user_forces() {
  # Ensure dir_1/file_1 and dir_2/file_1 exist with different contents
  mkdir "$DIR_1" "$DIR_2"
  echo 'This is dir_1/file_1.' > "$DIR_1_FILE_1"
  echo 'This is dir_2/file_1.' > "$DIR_2_FILE_1"

  createSpy -r 0 setdown_getconsent # User consents

  assertCommandTrue "Returned false when user forced copy" \
    setdown_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertEquals "Copy destination was not forcefully overwritten" \
    "$(cat "$DIR_1_FILE_1")" "$(cat "$DIR_2_FILE_1")"

  assertCallCount "Prompt was not displayed to force linking" \
    setdown_getconsent 1
  assertCalledWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $DIR_1 to $DIR_2, try forcing?"
}

test_copy_directory_destination_exists_user_does_not_force() {
  # Ensure dir_1/file_1 and dir_2/file_1 exist with different contents
  mkdir "$DIR_1" "$DIR_2"
  echo 'This is dir_1/file_1.' > "$DIR_1_FILE_1"
  echo 'This is dir_2/file_1.' > "$DIR_2_FILE_1"

  createSpy -r 1 setdown_getconsent # User does not consent

  assertCommandFalse "Returned true when copy failed and user didn't force" \
    setdown_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertEquals "Copy destination was overwritten without consent" \
    "This is dir_2/file_1." "$(cat "$DIR_2_FILE_1")"

  assertCallCount "Prompt was not displayed to force linking" \
    setdown_getconsent 1
  assertCalledWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $DIR_1 to $DIR_2, try forcing?"
}
