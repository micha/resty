
OUT=$(mktemp)
ERR=$(mktemp)
trap 'rm -f "$OUT" "$ERR"' EXIT

_test_ok=0
_counter=0
_status=
_stdout=
_stderr=
_count_fail=0
_expected=""

function describe() {
  echo -ne "\e[94m[....]" "$@" "\e[0m "
}

function ensure() {
  _status=
  _stdout=
  _stderr=
  _test_ok=0
  echo > $OUT
  echo > $ERR
  eval "${1?}" > $OUT 2> $ERR
  _status=$?
  _stdout=$(cat $OUT)
  _stderr=$(cat $ERR)
}

function _passing() {
  [ "$_test_ok" == "0" ]
}

function status() {
  if _passing
  then
    [ "$_status" == "${1?}" ]
    _test_ok=$?
    _expected="status == $1"
  fi
}

function stdout() {
  if _passing
  then
    [ "$_stdout" == "${1?}" ]
    _test_ok=$?
    _expected="stdout == $1"
  fi
}

function end() {
  if _passing
  then
    echo -e "\r\e[32m[PASS]\e[0m"
  else
    _count_fail=$((_count_fail+1))
    echo -e "\r\e[31m[FAIL]\e[0m"
    echo "status: ${_status}"
    echo "stdout: ${_stdout}"
    echo "stderr: ${_stderr}"
    echo "expect: ${_expected}"
  fi
}

function finished() {
  exit $_count_fail
}

function yellow() {
  echo -e "\e[33m${1?}\e[0m"
}
