#!/bin/sh

# Member of array returns `true` with no output
test_string_is_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  assertCommandTrue "Returned false for member string" \
    setdown_hasstr fruits 'cherry'
  assertCommandOutputNull
}

# Non-member returns `false` with no output
test_string_is_not_in_array() {
  # shellcheck disable=SC2034
  declare -a fruits=(apple banana cherry)
  assertCommandFalse "Returned true for non-member string" \
    setdown_hasstr fruits 'celery'
  assertCommandOutputNull
}
