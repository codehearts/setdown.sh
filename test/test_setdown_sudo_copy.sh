#!/bin/sh

test_copy_file_destination_does_not_exist() {
  touch "$FILE_1"

  createSpy setdown_getconsent
  createSpy -r 0 sudo # cp succeeds

  assertCommandTrue "Returned false when file was successfully copied" \
    setdown_sudo_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertNeverCalled "Prompt displayed when copy was performed successfully" \
    setdown_getconsent

  assertCalledOnceWith_ "Copy performed without calling sudo" \
    sudo cp -r "$FILE_1" "$FILE_2"

  # Call arguments to sudo to ensure they behave as desired
  cp -r "$FILE_1" "$FILE_2"

  assertTrue "Copy destination does not exist" \
    "[ -e $FILE_2 ]"
}

test_copy_file_destination_is_same_file() {
  # Ensure file_1 and file_2 exist with the same contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 1.' > "$FILE_2"

  createSpy setdown_getconsent
  createSpy -r 0 sudo # cp skipped (-e $2), cmp succeeds

  assertCommandTrue "Returned false when destination was already same file" \
    setdown_sudo_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertEquals "Copy destination does not exist with same contents" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"

  assertNeverCalled "Prompt was displayed when copy was unneeded" \
    setdown_getconsent

  # FILE_2 exists, so initial copy is not attempted
  assertCalledOnceWith_ "Compare performed without calling sudo" \
    sudo cmp -s "$FILE_1" "$FILE_2"
}

test_copy_file_destination_is_different_file_user_forces() {
  # Ensure file_1 and file_2 exist with different contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 2.' > "$FILE_2"

  createSpy -r 0 setdown_getconsent # User consents
  createSpy -r 1 -r 0 sudo # cp skipped (-e $2), cmp fails, cp succeeds

  assertCommandTrue "Returned false when user forced copy" \
    setdown_sudo_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $FILE_1 to $FILE_2, try forcing?"

  assertCallCount "Sudo was called too many times" \
    sudo 2
  # FILE_2 exists, so initial copy is not attempted
  assertCalledWith_ "Compare performed without calling sudo" \
    sudo cmp -s "$FILE_1" "$FILE_2"
  assertCalledWith_ "Copy forcefully performed without calling sudo" \
    sudo cp -rf "$FILE_1" "$FILE_2"

  # Call arguments to sudo to ensure they behave as desired
  cp -rf "$FILE_1" "$FILE_2"

  assertEquals "Copy destination was not forcefully overwritten" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"
}

test_copy_file_destination_is_different_file_user_does_not_force() {
  # Ensure file_1 and file_2 exist with different contents
  echo 'This is file 1.' > "$FILE_1"
  echo 'This is file 2.' > "$FILE_2"

  createSpy -r 1 setdown_getconsent # User does not consent
  createSpy -r 1 sudo # cp skipped (-e $2), cmp fails, cp skipped (getconsent)

  assertCommandFalse "Returned true when dest exists and user didn't force" \
    setdown_sudo_copy "$FILE_1" "$FILE_2"
  assertCommandOutputNull

  assertNotEquals "Copy destination was overwritten without consent" \
    "$(cat "$FILE_1")" "$(cat "$FILE_2")"

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $FILE_1 to $FILE_2, try forcing?"

  # FILE_2 exists, so initial copy is not attempted
  assertCalledOnceWith_ "Compare performed without calling sudo" \
    sudo cmp -s "$FILE_1" "$FILE_2"
}

test_copy_directory_destination_does_not_exist() {
  mkdir "$DIR_1"

  createSpy setdown_getconsent
  createSpy -r 0 sudo # cp succeeds

  assertCommandTrue "Returned false when directory was successfully copied" \
    setdown_sudo_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertNeverCalled "Prompt displayed when copy was performed successfully" \
    setdown_getconsent

  assertCalledOnceWith_ "Copy performed without calling sudo" \
    sudo cp -r "$DIR_1" "$DIR_2"

  # Call arguments to sudo to ensure they behave as desired
  cp -r "$DIR_1" "$DIR_2"

  assertTrue "Copy destination does not exist" \
    "[ -e $DIR_2 ]"
}

test_copy_directory_destination_exists_user_forces() {
  # Ensure dir_1/file_1 and dir_2/file_1 exist with different contents
  mkdir "$DIR_1" "$DIR_2"
  echo 'This is dir_1/file_1.' > "$DIR_1_FILE_1"
  echo 'This is dir_2/file_1.' > "$DIR_2_FILE_1"

  createSpy -r 0 setdown_getconsent # User consents
  createSpy -r 0 sudo # cp skipped (-e $2), cmp skipped (! -f $1), cp succeeds

  assertCommandTrue "Returned false when user forced copy" \
    setdown_sudo_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $DIR_1 to $DIR_2, try forcing?"

  # DIR_2 exists, so initial copy is not attempted
  # Compare not performed because DIR_2 is a directory
  assertCalledOnceWith_ "Copy forcefully performed without calling sudo" \
    sudo cp -rf "$DIR_1" "$DIR_2"

  # Call arguments to sudo to ensure they behave as desired
  cp -rf "$DIR_1" "$DIR_2"

  assertEquals "Copy destination was not forcefully overwritten" \
    "$(cat "$DIR_1_FILE_1")" "$(cat "$DIR_2_FILE_1")"
}

test_copy_directory_destination_exists_user_does_not_force() {
  # Ensure dir_1/file_1 and dir_2/file_1 exist with different contents
  mkdir "$DIR_1" "$DIR_2"
  echo 'This is dir_1/file_1.' > "$DIR_1_FILE_1"
  echo 'This is dir_2/file_1.' > "$DIR_2_FILE_1"

  createSpy -r 1 setdown_getconsent # User does not consent
  createSpy sudo # cp skipped (-e $2), cmp skipped (! -f $1), cp skipped (getconsent)

  assertCommandFalse "Returned true when copy failed and user didn't force" \
    setdown_sudo_copy "$DIR_1" "$DIR_2"
  assertCommandOutputNull

  assertEquals "Copy destination was overwritten without consent" \
    "This is dir_2/file_1." "$(cat "$DIR_2_FILE_1")"

  assertCalledOnceWith_ "Prompt displayed with wrong message" \
    setdown_getconsent "Couldn't copy $DIR_1 to $DIR_2, try forcing?"

  # DIR_2 exists, so initial copy is not attempted
  # Compare not performed because DIR_2 is a directory
  assertNeverCalled "Sudo was called when unneeded" \
    sudo
}
