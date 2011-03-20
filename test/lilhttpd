#!/usr/bin/env bash

[ "$1" = "-I" ] && reflect="yes"

while read a; do
  a=$(echo "$a" |tr -d '\r')
  if [ -n "$r" ]; then
    r=$(printf "%s\\n%s" "$r" "$a")
  else
    r="$a"
    f=$(echo "$a" |cut -d" " -f2 |sed -e 's@^/@@' -e 's/?.*//')
  fi
  [ "${a/#Content-Length: /}" = "$a" ] || n=${a/#Content-Length: /}
  [ "$a" = "" ] && break
done

[ -n "$n" ] && r=$(printf "%s\\n%s" "$r" "$(head -c $n)")

if [ "$reflect" = "yes" ]; then 
  ct="text/plain"
else
  r=$(cat "$f")
  ct=$(file -b --mime "$f")
fi

cat <<EOF
HTTP/1.0 200 OK
Cache-Control: private
Content-Type: $ct
Server: lilhttpd/1.0
Connection: close
Content-Length: $(echo "$r" |wc -c |awk '{print $1}')

$r
EOF
