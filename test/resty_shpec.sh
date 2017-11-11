[[ "$SHELL" == "bash" ]] && shopt -s expand_aliases # needed for bash

describe "Resty"

    describe "Basic"
        it "load resty function without error"
           source ./resty -W # source resty with no history mode
           assert equal $? 0
        end

        it "can define a target"
            output=$(resty localhost:4004 2>&1)
            assert equal $? 0
            assert equal "$output" "http://localhost:4004*"
        end

        # Launch server
        resty localhost:4004 2>/dev/null

        it "can access to it with a get"
            output=$(GET / 2>&1)
            assert present "$output"
        end
        it "get the good content"
            output=$(GET /simple.txt)
            assert equal "$output" "hi there"
        end

    end


    describe "HTTP Verbs"
        data='data here'
        it "GET"
            output=$(GET /echo)
            assert equal "$output" "get"
        end
        it "GET with query string"
            output=$(GET "/echo?a=b" -Q)
            assert equal "$output" 'get\n{"a":"b"}'
        end

        it "GET with query string by argument"
            output=$(GET /echo -q "a=b")
            assert equal "$output" 'get\n{"a":"b"}'
        end
        it "POST with data"
            output=$(POST /echo "$data")
            assert equal "$output" "post\n$data"
        end
        it "POST with data and query parameter"
            output=$(POST /echo "$data" -q "a=b")
            assert equal "$output" 'post\n'"$data"'\n{"a":"b"}'
        end
        it "PUT with data"
            output=$(PUT /echo "$data")
            assert equal "$output" "put\n$data"
        end
        it "PUT with data and query parameter"
            output=$(PUT /echo "$data" -q "a=b")
            assert equal "$output" 'put\n'"$data"'\n{"a":"b"}'
        end
        it "PATCH with data"
            output=$(PATCH /echo "$data")
            assert equal "$output" "patch\n$data"
        end
        it "PATCH with data and query parameter"
            output=$(PATCH /echo "$data" -q "a=b")
            assert equal "$output" 'patch\n'"$data"'\n{"a":"b"}'
        end
        it "DELETE"
            output=$(DELETE /echo)
            assert equal "$output" "delete"
        end
        it "DELETE with data"
            output=$(DELETE /echo "$data")
            assert equal "$output" "delete\n$data"
        end
        it "TRACE"
            output=$(TRACE /echo "$data")
            assert equal "$output" "trace\n$data"
        end
        it "OPTIONS"
            output=$(OPTIONS /echo)
            assert equal "$output" "options"
        end
        it "HEAD"
            output=$(HEAD /echo)
            assert grep "$output" "200"
        end

    end

    describe "Viewer"

        it "prety format when lynx is installed"
            output=$(GET /simple.html | tr -d ' ')
            assert grep $(which lynx) lynx
            assert equal "$output" "$(cat test/test-data/simple-html-lynx.txt | tr -d ' ')"
            # note : hack to cope with lynx version differencies and different handling of table headers
        end
        it "does not prety format on raw mode"
            output=$(GET /simple.html -Z)
            assert equal "$output" "$(< test/data/simple.html)"
        end
        it "json pretty-print formatting with pypp"
            output=$(GET /simple.json | ./pypp)
            assert equal "$output" '{\n    "bar": {
        "cat": "meow",\n        "dog": "woof",\n        "fish": "banana"\n    },\n    "foo": [
        1,\n        2,\n        3\n    ]\n}'
        end
    end

    describe "Curl Failures"
        it "are reported to the user"
            stub_command curl "echo '* Connected to mysite.com (64.136.20.67) port 443 (#0)
* Server aborted the SSL handshake
* Closing connection 0' >&2; return 2"
            output=$(GET /simple.html -Z 2>&1)
            assert unequal $? 0
            assert equal "$output" "* Connected to mysite.com (64.136.20.67) port 443 (#0)
* Server aborted the SSL handshake
* Closing connection 0"
            unstub_command curl

        end
    end

    describe "Options"
         it "GET with headers"
            output=$(GET /echo -v 2> /tmp/resty-getheader-error)
            erroroutput=$(< /tmp/resty-getheader-error)
            assert equal "$output" "get"
            assert grep "$erroroutput" "content-type:"
            assert grep "$erroroutput" "cache-control:"
        end

        it "POST with data sent in query string"
            output=$(POST /echo -d 'foo=bar' -G)
            assert equal "$output" 'post\n\n{"foo":"bar"}'
            echo "     note a strange behavior on osx where query send has a '&' in it"
        end

        it "POST with extra header and basic auth, data in message body"
            output=$(POST /echo -u "user:secret" -H "Accept: application/json" \
                     -v < test/data/simple.json 2> /tmp/resty-getheader-error)
            erroroutput=$(< /tmp/resty-getheader-error)
            assert equal "$output" 'post\n{"foo":[1,2,3],"bar":{"dog":"woof","cat":"meow","fish":"banana"}}'
            assert grep "$erroroutput" "Authorization:\ Basic\ dXNlcjpzZWNyZXQ="
            assert grep "$erroroutput" "Accept:\ application/json"
        end

        it "POST with extra header and basic auth, data in message body and --json option"
            output=$(POST /echo -u "user:secret" --json \
                     -v < test/data/simple.json 2> /tmp/resty-getheader-error)
            erroroutput=$(< /tmp/resty-getheader-error)
            assert equal "$output" 'post\n{"foo":[1,2,3],"bar":{"dog":"woof","cat":"meow","fish":"banana"}}'
            assert grep "$erroroutput" "Authorization:\ Basic\ dXNlcjpzZWNyZXQ="
            assert grep "$erroroutput" "Accept:\ application/json"
        end

    end

    describe "Resty Global options"
        it "Setting new options"
            resty localhost:4004 -u "user:secret" -H "Accept: application/json" 2> /dev/null
            output=$(GET /echo -v 2> /tmp/resty-newopt-error)
            erroroutput=$(< /tmp/resty-newopt-error)
            assert equal "$output" "get"
            assert grep "$erroroutput" "Authorization:\ Basic\ dXNlcjpzZWNyZXQ="
            assert grep "$erroroutput" "Accept:\ application/json"
        end

        it "Resetting options"
            resty localhost:4004 2> /dev/null
            output=$(GET /echo -v 2> /tmp/resty-resetopt-error)
            erroroutput=$(< /tmp/resty-resetopt-error)
            assert equal "$output" "get"
            assert no_grep "$erroroutput" "Authorization:\ Basic\ dXNlcjpzZWNyZXQ="
            assert no_grep "$erroroutput" "Accept:\ application/json"
        end
    end

    describe "Preserve Path Argument"
        it "works by default"
            GET /echo > /dev/null
            assert equal "$_RESTY_PATH" "/echo"
            output=$(GET)
            assert equal "$output" "get"
        end

        it "can be disabled"
            RESTY_NO_PRESERVE_PATH="yes"
            _RESTY_PATH="" # reset RESTY_PATH
            GET /echo > /dev/null
            assert equal "$_RESTY_PATH" ""
            output=$(GET 2>&1)
            assert grep "$output" '{"statusCode":403'
            RESTY_NO_PRESERVE_PATH="no"
        end
    end


    describe "Host defined Options"
        it "are setted at resty when host match"
            XDG_CONFIG_HOME=./test/test-data
            resty localhost:4004 2> /dev/null
            assert equal "$_RESTY_OPT_DEFAULT_GET" "-Q"
            assert equal "${_RESTY_OPT_HOST_GET[*]}" "-H 'Accept: text/plain'"
            assert equal "$_RESTY_OPT_HOST_POST" "--json"
        end
        it "are used when performing a query"
            output=$(GET "/echo?a=b" -v 2> /tmp/resty-resetopt-error)
            erroroutput=$(< /tmp/resty-resetopt-error)
            assert equal "$output" 'get\n{"a":"b"}'
            assert grep "$erroroutput" "Accept:\ text/plain"

            output=$(POST /echo "{\"a\": \"b\"}"  -v 2> /tmp/resty-resetopt-error)
            erroroutput=$(< /tmp/resty-resetopt-error)
            assert equal "$output" 'post\n{"a": "b"}'
            assert grep "$erroroutput" "Content-Type:\ application/json"
            assert grep "$erroroutput" "Accept:\ application/json"
        end
        it "are setted at resty with host match and defaults and config are merged"
            XDG_CONFIG_HOME=./test/test-data
            resty localhost:4004 -u "user:secret with space" 2> /dev/null
            assert equal "$_RESTY_OPT_DEFAULT_GET" "-Q"
            assert equal "${_RESTY_OPT_HOST_GET[*]}" "-H 'Accept: text/plain'"
            assert equal "$_RESTY_OPT_HOST_POST" "--json"
            assert equal "$_RESTY_OPTS" "-u user:secret\\ with\\ space"
            query="$(GET "/echo?a=b" --dry-run)"
            assert equal "$query" "curl -sLv '' -X GET -b \"/resty/c/localhost:4004\" -c \"/resty/c/localhost:4004\" -H 'Accept: text/plain' -u user:secret\\ with\\ space \"http://localhost:4004/echo?a=b\""
        end
        it "are unsetted at resty when no host match"
            resty localhost:4005 2> /dev/null
            assert equal "$_RESTY_OPT_DEFAULT_GET" "-Q"
            assert equal "$_RESTY_OPT_HOST_GET" ""
            assert equal "$_RESTY_OPT_HOST_POST" ""
        end
    end
end
