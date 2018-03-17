#!/usr/bin/env bash

source "setdown.sh"

test_hascmd() {
  assertTrue "True for installed commands" "setdown_hascmd cat"
  assertFalse "False for missing commands" "setdown_hascmd doesnotexist"
}

. test/shunit2/shunit2
