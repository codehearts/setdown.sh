#!/bin/sh

# Provides all setup and teardown functions, and performs assertions
# to catch mistakes and reduce complexity in testcases.
#
# The following functions are provided and required for each testcase.
# One of assertCommandTrue or assertCommandFalse must be called.
# One of assertCommandOutputEquals or assertCommandOutputNull must be called.
# - assertCommandTrue [msg] [cmd_args...]
#     Asserts if the given command is false, displayng the given message.
# - assertCommandFalse [msg] [cmd_args...]
#     Asserts if the given command is false, displayng the given message.
# - assertCommandOutputEquals [expected_output]
#     Asserts if the output from assertCommandTrue or assertCommandFalse is
#     not equal to the expected output.
# - assertCommandOutputNull
#     Asserts if assertCommandTrue or assertCommandFalse had output.
#
# The following variables are provided for all test cases to use:
# - FILE_1: File path for use in tests.
#           This file is removed between testcases.
# - FILE_2: File path for use in tests.
#           This file is removed between testcases.
# - FILE_3: File path for use in tests.
#           This file is removed between testcases.
# - DIR_1_FILE_1: File path inside DIR_1 for use in tests.
#                 This file is removed between testcases.
# - DIR_1_FILE_2: File path inside DIR_1 for use in tests.
#                 This file is removed between testcases.
# - DIR_2_FILE_1: File path inside DIR_2 for use in tests.
#                 This file is removed between testcases.
# - DIR_2_FILE_2: File path inside DIR_2 for use in tests.
#                 This file is removed between testcases.
# - DIR_1: Directory path for use in tests.
#          If this directory is created, it will be removed between testcases.
# - DIR_2: Directory path for use in tests.
#          If this directory is created, it will be removed between testcases.
#

# Print usage information if the wrong number of arguments are passed
if [ $# -ne 1 ]; then
  echo "Useage: $0 test_file.sh"
  echo "  Exactly 1 test file must be passed"
  exit 1
fi



#
# Test setup & teardown
#

# Run once before the first test is run
oneTimeSetUp() {
  # Create a directory for test metadata with a file for storing command output
  readonly _TEST_META_DIR=$(mktemp -d)
  readonly _COMMAND_OUTPUT_FILE="$_TEST_META_DIR/command_output"

  # Create temporary files for use in testing
  readonly _FILE_DIR="$_TEST_META_DIR/files/"
  readonly FILE_1="$_FILE_DIR/file_1"
  readonly FILE_2="$_FILE_DIR/file_2"
  readonly FILE_3="$_FILE_DIR/file_3"
  readonly DIR_1="$_FILE_DIR/dir_1"
  readonly DIR_2="$_FILE_DIR/dir_2"
  readonly DIR_1_FILE_1="$DIR_1/file_1"
  readonly DIR_1_FILE_2="$DIR_1/file_2"
  readonly DIR_2_FILE_1="$DIR_2/file_1"
  readonly DIR_2_FILE_2="$DIR_2/file_2"
}

# Run once after the last test is run
oneTimeTearDown() {
  # Delete the test metadata directory
  rm -rf "$_TEST_META_DIR"
}

# Run before each test
setUp() {
  # Flag to ensure each test case verifies its command output
  _COMMAND_OUTPUT_VERIFIED=false

  # Create the temporary file directory
  mkdir "$_FILE_DIR"
}

# Run after each test
tearDown() {
  # If no command output exists, _run_test_command was not called so we assert
  assertTrue \
    "Missing call to assertCommandTrue or assertCommandFalse" \
    "[ -e $_COMMAND_OUTPUT_FILE ]"

  # If command output was not verified, assert
  assertTrue \
    "Missing call to assertCommandOutputEquals or assertCommandOutputNull" \
    "$_COMMAND_OUTPUT_VERIFIED"

  # Remove the command output file and temporary files
  rm -rf "$_COMMAND_OUTPUT_FILE" "$_FILE_DIR"

  # Restore all spies
  cleanupSpies
}



#
# Private functions
#

# Runs the given arguments as a command
# Output is redirected to the command output file
#   _run_test_command cp "$FILE_1" "$FILE_2"
_run_test_command() {
  "$@" > "$_COMMAND_OUTPUT_FILE" 2>&1
}

# Takes a message followed by expected command output from _run_test_command
# If the command output does not match, an assertion is raised
# from _run_test_command
#   _assert_command_output_equals "Unexpected output" "No such file"
_assert_command_output_equals() {
  _COMMAND_OUTPUT_VERIFIED=true
  assertEquals "$1" "$2" "$(cat "$_COMMAND_OUTPUT_FILE")"
}



#
# Public functions
#

# Takes a message followed by a command and its arguments
# If the command returns false, an assertion is raised
#   assertCommandTrue "Copy failed unexpectedly" cp "$FILE_1" "$FILE_2"
assertCommandTrue() {
  # Store the message argument and shift it off the stack
  local MESSAGE="$1"
  shift

  _run_test_command "$@"
  assertTrue "$MESSAGE" "$?"
}

# Takes a message followed by a command and its arguments
# If the command returns true, an assertion is raised
#   assertCommandFalse "Copy succeeded unexpectedly" cp "$FILE_1" "$FILE_1"
assertCommandFalse() {
  # Store the message argument and shift it off the stack
  local MESSAGE="$1"
  shift

  _run_test_command "$@"
  assertFalse "$MESSAGE" "$?"
}

# Asserts if the command output does not match the given argument
#   assertCommandOutputEquals "No such file or directory"
assertCommandOutputEquals() {
  _assert_command_output_equals "Unexpected command output" "$1"
}

# Asserts if the command output is not empty
#   assertCommandOutputNull
assertCommandOutputNull() {
  _assert_command_output_equals "Command output was not suppressed" ""
}



#
# Source & run tests
#

readonly TEST_NAME="$(basename "$1")"

echo -e "\\nRunning $TEST_NAME:\\n"
# shellcheck source=/dev/null
. ./test/"$TEST_NAME"
# shellcheck source=/dev/null
. ./setdown.sh
# shellcheck source=/dev/null
. ./test/shpy
# shellcheck source=/dev/null
. ./test/shpy-shunit2
# shellcheck source=/dev/null
. ./test/shunit2
