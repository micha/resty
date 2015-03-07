#!/usr/bin/env bash

# start nodejs web server
node app.js &
NODE_PID=$!

# bring resty into env
. ../resty


