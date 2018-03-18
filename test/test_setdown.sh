#!/usr/bin/env bash

declare -r TEST_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${TEST_DIRECTORY}/../setdown.sh"

test_hascmd() {
  assertTrue "True for installed commands" "setdown_hascmd cat"
  assertFalse "False for missing commands" "setdown_hascmd doesnotexist"
}

test_hasstr() {
  declare -a fruits=(apple banana cherry)
  assertTrue "True for strings in array" "setdown_hasstr fruits 'cherry'"
  assertFalse "False for strings not in array" "setdown_hasstr fruits 'celery'"
}

. $TEST_DIRECTORY/shunit2/shunit2
