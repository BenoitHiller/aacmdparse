#!/bin/bash
source aacmdparse.bash

fail() {
  echo test failed >&2
  caller 0 >&2
  echo parse results >&2
  declare -p argMap >&2
  declare -p vargs >&2
  exit 1
}

test1() {
  aacmdparse 1 -p -fb 3 -s 5 --test test1 -- -d

  [[ ${#argMap[@]} == 5 ]] || fail

  [[ ${vargs[0]} == 1 ]] || fail

  [[ ${vargs[2]} == 5 ]] || fail

  [[ -z "${argMap[test]}" ]] || fail

}

test2() {
  local -a assignableParameters=( s test )

  aacmdparse 1 -p -fb 3 -s 5 --test test1 -- -d

  [[ ${#argMap[@]} == 5 ]] || fail

  [[ ${vargs[0]} == 1 ]] || fail

  [[ ${vargs[1]} == 3 ]] || fail

  [[ ${vargs[2]} == "-d" ]] || fail

  [[ ${argMap[s]} == 5 ]] || fail

  [[ "${argMap[test]}" == "test1" ]] || fail

}

test1
test2

echo all tests passed >&2
