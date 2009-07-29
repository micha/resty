#
# resty - A tiny command line REST interface for bash.
#
# Fork me on github:
#   http://github.com/micha/resty
#
# Author:
#   Micha Niskin <micha@thinkminimo.com>
#   Copyright 2009, no rights reserved.
#

export _resty=""

function resty() {
  local conf="${HOME}/.restyrc"
  local host=`cat "$conf" 2>/dev/null`
  local method="$1";          [[ $# > 0 ]] && shift
  local h2t=$((which lynx >/dev/null && echo lynx -stdin -dump) \
                || which html2text || which cat)
  local accp="Accept: application/json"
  local uri opt dat res ret out err verbose raw i d tmpf

  [ -n "$1" ] && [ "${1#/}" != "$1" ] && uri="$1" && shift
  [ -z "$method" ] && cat "$conf" 2>/dev/null && return

  for i in "$@"; do
    ([ "$i" == "--verbose" ] || echo "$i" | grep -q '^-[a-zA-Z]*v[a-zA-Z]*$') \
      && verbose="yes"
  done

  [ -n "$uri" ] && _resty=$uri
  uri="${host//\*/$_resty}"

  case "$method" in
    GET|DELETE|POST|PUT)
      dat=$( ( [ "${method#P}" != "$method" ] \
        && ( ( [ -n "$1" ] && [ "${1#-}" == "$1" ] && echo "$1") \
        || echo "@-") ) || echo)
      if [ "${method#P}" != "$method" ] && [ "$1" == "-V" ]; then
        tmpf=$(mktemp /tmp/resty.XXXXXX)
        cat > $tmpf
        (exec < /dev/tty; vi $tmpf)
        dat=$(cat $tmpf)
        rm -f $tmpf
      fi
      [ -n "$dat" ] && [ "$dat" != "@-" ] && shift
      [ "$1" == "-Z" ] && raw="yes" && shift
      [ -n "$dat" ] && opt="--data-binary"
      res=$((((curl -sLv -H "$accp" $opt "$dat" -X $method "$@" "$uri" \
        |sed 's/^/OUT /' && echo) 3>&2 2>&1 1>&3) \
        |sed 's/^/ERR /' && echo) 2>&1)
      out=$(echo "$res" |sed '/^OUT /s/^....//p; d')
      err=$(echo "$res" |sed '/^ERR /s/^....//p; d')
      ret=$(echo "$err" |sed \
        '/^.*HTTP\/1\.[01] [0-9][0-9][0-9]/s/.*\([0-9]\)[0-9][0-9].*/\1/p; d' \
        | tail -n1)
      [ -n "$err" -a -n "$verbose" ] && echo "$err" 1>&2
      echo "$err" | grep -qi '^< \s*Content-Type:  *text/html' \
        && [ -z "$raw" ] && d=$h2t || d=cat
      if [ "$ret" != "2" ]; then
        [ -n "$out" ] && echo "$out" | $d 1>&2
        return $ret
      else
        [ -n "$out" ] && echo "$out" | $d
      fi
      ;;
    http://*|https://*)
      echo "$method" |grep -q '\*' || method="${method}*"
      (echo "$method" |tee "$conf") |cat 1>&2
      ;;
    *)
      resty "http://$method"
      ;;
  esac
}

function GET() {
  resty GET "$@"
}

function POST() {
  resty POST "$@"
}

function PUT() {
  resty PUT "$@"
}

function DELETE() {
  resty DELETE "$@"
}
