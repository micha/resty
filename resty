#
# resty - A tiny command line REST interface for bash and zsh.
#
# Fork me on github:
#   http://github.com/micha/resty
#
# Author:
#   Micha Niskin <micha@thinkminimo.com>
#   Copyright 2009, no rights reserved.
#

export _resty_host=""
export _resty_path=""
export _resty_nohistory=""

function resty() {
  local confdir datadir host cookies method h2t editor domain _path opt dat res ret out err verbose raw i j d tmpf args2 wantdata vimedit quote query maybe_query
  local -a curlopt
  local -a curlopt2

  if [ -n "$XDG_CONFIG_HOME" ]; then
    confdir="$XDG_CONFIG_HOME/resty"
    datadir="$XDG_DATA_HOME/resty"
  else
    confdir="$HOME/.resty"
    datadir="$confdir"
  fi
  mkdir -p "$confdir"
  host="$datadir/host"
  cookies="$datadir/c"
  method="$1"; [[ $# > 0 ]] && shift
  h2t=$((exec 2>&-; (which lynx >/dev/null && echo lynx -stdin -dump) \
                || which html2text || which cat) |tail -n 1)
  editor=$((exec 2>&-; which "$EDITOR" || which vim || echo "vi") |tail -n 1)
  
  [ "${method#P}" != "$method" ] || [ "$method" = "TRACE" ] && wantdata="yes"

  [ -d "$cookies" ] || (mkdir -p "$cookies"; echo "http://localhost*" > "$host")
  [ -n "$1" ] && [ "${1#/}" != "$1" ] \
    && _path="$1" && [[ $# > 0 ]] && shift
  [ "$1" = "${1#-}" ] && dat="$1" && [[ $# > 0 ]] && shift
  
  j=1
  for i in "$@"; do
    [ -n "$maybe_query" -a -z "$query" ] && query="?$i" && continue
    ([ "$i" = "--verbose" ] || echo "$i" | grep '^-[a-zA-Z]*v[a-zA-Z]*$' >/dev/null) \
      && verbose="yes" && continue
    [ "$i" = "-V" ] && vimedit="yes" && continue
    [ "$i" = "-Z" ] && raw="yes" && continue
    [ "$i" = "-W" ] && continue
    [ "$i" = "-Q" ] && quote="yes" && continue
    [ "$i" = "-q" ] && maybe_query="yes" && continue
    curlopt[j]="$i" && j=$((j + 1))
  done

  [ -z "$quote" ] && _path=$(echo "$_path"|sed 's/%/%25/g;s/\[/%5B/g;s/\]/%5D/g;s/|/%7C/g;s/\$/%24/g;s/&/%26/g;s/+/%2B/g;s/,/%2C/g;s/:/%3A/g;s/;/%3B/g;s/=/%3D/g;s/?/%3F/g;s/@/%40/g;s/ /%20/g;s/#/%23/g;s/{/%7B/g;s/}/%7D/g;s/\\/%5C/g;s/\^/%5E/g;s/~/%7E/g;s/`/%60/g')

  [ "$method" = "HEAD" ] || [ "$method" = "OPTIONS" ] && raw="yes"
  [ -z "$_resty_host" ] && _resty_host=$(cat "$host" 2>/dev/null)
  [ "$method" = "-v" ] && echo "$_resty_host $_resty_opts" && return
  [ -z "$method" ] && echo "$_resty_host" && return
  [ -n "$_path" ] && _resty_path=$_path
  domain=$(echo -n "$_resty_host" \
    |perl -ane '/^https?:\/\/([^\/\*]+)/; print $1')
  _path="${_resty_host//\*/$_resty_path}"

  case "$method" in
    HEAD|OPTIONS|GET|DELETE|POST|PUT|TRACE)
      eval "curlopt2=(${_resty_opts[*]})"
      dat=$( ( [ "$wantdata" = "yes" ] \
        && ( ( [ -n "$dat" ] && echo "$dat") \
        || ([ ! -t 0 ] && echo "@-") ) ) || echo)
      if [ "$wantdata" = "yes" ] && [ "$vimedit" = "yes" ]; then
        tmpf=$(mktemp /tmp/resty.XXXXXX)
        [ -t 0 ] || cat > $tmpf
        (exec < /dev/tty; "$editor" $tmpf)
        dat=$(cat $tmpf)
        rm -f $tmpf
      fi
      [ -n "$dat" ] && [ "$dat" != "@-" ] && [[ $# > 0 ]] && shift
      [ "$1" = "-Z" ] && raw="yes" && [[ $# > 0 ]] && shift
      [ -n "$dat" ] && opt="--data-binary"
      [ "$method" = "HEAD" ] && opt="-I" && raw="yes"
      eval "args2=( $(cat "$confdir/$domain" 2>/dev/null |sed 's/^ *//' |grep ^$method |cut -b $((${#method}+2))-) )"
      res=$((((curl -sLv $opt "$dat" -X $method \
              -b "$cookies/$domain" -c "$cookies/$domain" \
              "${args2[@]}" "${curlopt2[@]}" "${curlopt[@]}" "$_path$query" \
        |sed 's/^/OUT /' && echo) 3>&2 2>&1 1>&3) \
        |sed 's/^/ERR /' && echo) 2>&1)
      out=$(echo "$res" |sed '/^OUT /s/^....//p; d')
      err=$(echo "$res" |sed '/^ERR /s/^....//p; d')
      ret=$(echo "$err" |sed \
        '/^.*HTTP\/1\.[01] [0-9][0-9][0-9]/s/.*\([0-9]\)[0-9][0-9].*/\1/p; d' \
        | tail -n1)
      [ -n "$err" -a -n "$verbose" ] && echo "$err" 1>&2
      echo "$err" | grep -i '^< \s*Content-Type:  *text/html' >/dev/null \
        && [ -z "$raw" ] && d=$h2t || d=cat
      [ -n "$out" ] && out=$(echo "$out" |eval "$d")
      [ "$d" != "${d##lynx}" ] && out=$(echo "$out" |perl -e "\$host='$(echo "$_resty_host" |sed 's/^\(https*:\/\/[^\/*]*\).*$/\1/')';" -e '@a=<>; $s=0; foreach (reverse(@a)) { if ($_ =~ /^References$/) { $s++; } unless ($s>0) { s/^\s+[0-9]+\. //; s/^file:\/\/localhost/$host/; } push(@ret,$_); } print(join("",reverse(@ret)))')
      if [ "$ret" != "2" ]; then
        [ -n "$out" ] && echo "$out" 1>&2
        return $ret
      else
        [ -n "$out" ] && echo "$out"
      fi
      ;;
    http://*|https://*)
      _resty_opts=$(printf '%q ' "${curlopt[@]}")
      export _resty_opts
      echo "$method" |grep '\*' >/dev/null || method="${method}*"
      (echo "$method" |tee "${_resty_nohistory:-$host}") |cat 1>&2 \
        && _resty_host="$method"
      ;;
    *)
      resty "http://$method" "${curlopt[@]}"
      ;;
  esac
}

function HEAD() {
  resty HEAD "$@"
}

function OPTIONS() {
  resty OPTIONS "$@"
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

function TRACE() {
  resty TRACE "$@"
}

[ "$1" = "-W" ] && export _resty_nohistory="/dev/null" && [[ $# > 0 ]] && shift

resty "$@" >/dev/null 2>&1
