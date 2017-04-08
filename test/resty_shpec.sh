

describe "Resty"

    describe "Basic"
        it "load resty function without error"
           . ./resty -W # source resty with no history mode
           assert equal $? 0
        end

        it "can define a target"
            output=$(resty localhost:4004 2>&1 )
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
        it "POST with data"
            output=$(POST /echo "$data")
            assert equal "$output" "post\n$data"
        end
        it "PUT with data"
            output=$(PUT /echo "$data")
            assert equal "$output" "put\n$data"
        end
        it "PATCH with data"
            output=$(PATCH /echo "$data")
            assert equal "$output" "patch\n$data"
        end
        it "DELETE"
            output=$(DELETE /echo)
            assert equal "$output" "delete"
        end
        it "DELETE with data"
            output=$(DELETE /echo "$data" --body )
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

    end

    describe "Viewer"

        it "prety format when lynx is installed"
            output=$(GET /simple.html | tr -d ' ')
            assert match $(which lynx) lynx
            assert equal "$output" "$(cat test/test-data/simple-html-lynx.txt | tr -d ' ')"
            # note : hack to cope with lynx version differencies and different handling of table headers
        end
        it "does not prety format on raw mode"
            output=$(GET /simple.html -Z)
            assert equal "$output" "$(< test/data/simple.html)"
        end



    end

    describe "Options"
        echo "To be done"

    end

end