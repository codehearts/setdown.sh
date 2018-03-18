#!/usr/bin/env bash

declare TEST_DIRECTORY
TEST_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=/app/setdown.sh
source "${TEST_DIRECTORY}/../setdown.sh"

# shellcheck source=/dev/null
source "${TEST_DIRECTORY}/stub/stub.sh"

setUp() {
  mkdir files/
}

tearDown() {
  restore setdown_getconsent
  rm -rf files/
}

#
# setdown_link
#

test_setdown_link_link_does_not_exist() {
  touch files/my_file

  stub setdown_getconsent
  setdown_link files/my_file files/my_link > files/output 2>&1

  assertTrue \
    "Linking returned false when file was successfully linked" \
    "$?"
  assertEquals \
    "Link was created to wrong file" \
    "files/my_file" "$(readlink files/my_link)"
  assertFalse \
    "Prompt was displayed when link was created successfully" \
    "stub_called setdown_getconsent"
  assertNull "Output was not supressed" "$(cat files/output)"
}

test_setdown_link_link_already_exists_to_same_file() {
  touch files/my_file
  ln -s files/my_file files/my_link

  stub setdown_getconsent
  setdown_link files/my_file files/my_link > files/output 2>&1

  assertTrue \
    "Linking returned false when link to file already existed" \
    "$?"
  assertEquals \
    "Link was changed when it should have been left alone" \
    "files/my_file" "$(readlink files/my_link)"
  assertFalse \
    "Prompt was displayed when link should have been left alone" \
    "stub_called setdown_getconsent"
  assertNull "Output was not supressed" "$(cat files/output)"
}

test_setdown_link_link_already_exists_to_different_file_user_forces() {
  touch files/my_file files/my_file2
  ln -s files/my_file2 files/my_link

  stub_and_eval setdown_getconsent "true"
  setdown_link files/my_file files/my_link > files/output 2>&1

  assertTrue \
    "Linking returned false when link to file existed and user forced link" \
    "$?"
  assertEquals \
    "Link was not forcefully overwritten" \
    "files/my_file" \
    "$(readlink files/my_link)"
  assertEquals \
    "Prompt was not displayed when determining whether to force linking" \
    "1" \
    "$(stub_called_times 'setdown_getconsent')"
  assertTrue \
    "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link files/my_file to files/my_link, try forcing?\""
  assertNull "Output was not supressed" "$(cat files/output)"
}

test_setdown_link_link_already_exists_to_different_file_user_does_not_force() {
  touch files/my_file files/my_file2
  ln -s files/my_file2 files/my_link

  stub_and_eval setdown_getconsent "false"
  setdown_link files/my_file files/my_link > files/output 2>&1

  assertFalse \
    "Linking returned true when link was not made" \
    "$?"
  assertEquals \
    "Link was overwritten when it should not have been" \
    "files/my_file2" \
    "$(readlink files/my_link)"
  assertEquals \
    "Prompt was not displayed when determining whether to force linking" \
    "1" \
    "$(stub_called_times 'setdown_getconsent')"
  assertTrue \
    "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link files/my_file to files/my_link, try forcing?\""
  assertNull "Output was not supressed" "$(cat files/output)"
}

#
# setdown_hascmd
#

test_hascmd_command_exists() {
  setdown_hascmd cat > files/output 2>&1

  assertTrue "Returned false for installed command" "$?"
  assertNull "Output was not supressed" "$(cat files/output)"
}

test_hascmd_command_does_not_exist() {
  setdown_hascmd doesnotexist > files/output 2>&1

  assertFalse "Returned true for missing command" "$?"
  assertNull "Output was not supressed" "$(cat files/output)"
}

#
# setdown_hasstr
#

test_hasstr_string_is_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  setdown_hasstr fruits 'cherry' > files/output 2>&1

  assertTrue "Returned false for member" "$?"
  assertNull "Output was not supressed" "$(cat files/output)"
}

test_hasstr_string_is_not_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  setdown_hasstr fruits 'celery' > files/output 2>&1

  assertFalse "Returned true for non-member" "$?"
  assertNull "Output was not supressed" "$(cat files/output)"
}

# shellcheck source=/dev/null
. "$TEST_DIRECTORY/shunit2/shunit2"
