#!/usr/bin/env bash
DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

. $DIR/../resty
. $DIR/expect.sh

# start nodejs web server
yellow "<< Starting NodeJS server >>"
node $DIR/app.js > /dev/null 2>&1 &
NODE=$!

# wait for node server to start
sleep 1

describe "should have default uri base"
  ensure "resty"
    status 0
    stdout "http://localhost*"
end

describe "should be able to set uri base"
  ensure "resty localhost:8011"
    status 0
    stderr "http://localhost:8011*"
end

describe "should be able to GET /"
  ensure "GET /"
    status 0
    stdout "i am a beautiful butterfly"
end

yellow "<< Stopping NodeJS server >>"
kill $NODE > /dev/null 2>&1

finished
