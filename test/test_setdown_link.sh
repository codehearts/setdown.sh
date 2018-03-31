#!/usr/bin/env bash

# Create a unique file for each test to redirect command output to
oneTimeSetUp() {
  readonly COMMAND_OUTPUT_FILE=$(mktemp)
  readonly FILE_DIR=$(mktemp -d)
  readonly FILE_1="$FILE_DIR/file_1"
  readonly FILE_2="$FILE_DIR/file_2"
  readonly LINK="$FILE_DIR/link"
}

# Delete the temporary file directory after running all tests
oneTimeTearDown() {
  rm -rf "$FILE_DIR"
}

# Create the temporary files before each test
setUp() {
  touch "$FILE_1" "$FILE_2"
}

# Clear the command output file and remove temp files/links after each test
tearDown() {
  : > "$COMMAND_OUTPUT_FILE"
  rm -f "$FILE_1" "$FILE_2" "$LINK"
}



test_link_does_not_exist() {
  stub setdown_getconsent
  setdown_link "$FILE_1" "$LINK" > "$COMMAND_OUTPUT_FILE" 2>&1

  assertTrue \
    "Linking returned false when file was successfully linked" \
    "$?"
  assertEquals \
    "Link was created to wrong file" \
    "$FILE_1" "$(readlink "$LINK")"
  assertFalse \
    "Prompt was displayed when link was created successfully" \
    "stub_called setdown_getconsent"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}

test_link_already_exists_to_same_file() {
  ln -s "$FILE_1" "$LINK"

  stub setdown_getconsent
  setdown_link "$FILE_1" "$LINK" > "$COMMAND_OUTPUT_FILE" 2>&1

  assertTrue \
    "Linking returned false when link to file already existed" \
    "$?"
  assertEquals \
    "Link was changed when it should have been left alone" \
    "$FILE_1" "$(readlink "$LINK")"
  assertFalse \
    "Prompt was displayed when link should have been left alone" \
    "stub_called setdown_getconsent"
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}

test_link_already_exists_to_different_file_user_forces() {
  ln -s "$FILE_2" "$LINK"

  stub_and_eval setdown_getconsent "true"
  setdown_link "$FILE_1" "$LINK" > "$COMMAND_OUTPUT_FILE" 2>&1

  assertTrue \
    "Linking returned false when link to file existed and user forced link" \
    "$?"
  assertEquals \
    "Link was not forcefully overwritten" \
    "$FILE_1" \
    "$(readlink "$LINK")"
  assertEquals \
    "Prompt was not displayed when determining whether to force linking" \
    "1" \
    "$(stub_called_times 'setdown_getconsent')"
  assertTrue \
    "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link $FILE_1 to $LINK, try forcing?\""
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}

test_link_already_exists_to_different_file_user_does_not_force() {
  ln -s "$FILE_2" "$LINK"

  stub_and_eval setdown_getconsent "false"
  setdown_link "$FILE_1" "$LINK" > "$COMMAND_OUTPUT_FILE" 2>&1

  assertFalse \
    "Linking returned true when link was not made" \
    "$?"
  assertEquals \
    "Link was overwritten when it should not have been" \
    "$FILE_2" \
    "$(readlink "$LINK")"
  assertEquals \
    "Prompt was not displayed when determining whether to force linking" \
    "1" \
    "$(stub_called_times 'setdown_getconsent')"
  assertTrue \
    "Prompt displayed with wrong message" \
    "stub_called_with 'setdown_getconsent' \"Couldn't link $FILE_1 to $LINK, try forcing?\""
  assertNull "Output was not supressed" "$(cat "$COMMAND_OUTPUT_FILE")"
}
