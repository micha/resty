

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
        echo "To Be Done"

    end

    describe "Options"
        echo "To be done"

    end

end