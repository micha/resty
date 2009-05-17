Introduction
============

 * Put the `resty` script in your path somewhere.

    mv resty ~/bin/

 * Source the script before using it (you can put this line in your
   `~/.bashrc` file if you want).

    . ~/bin/resty

 * Set the REST host to which you will be making your requests (you
   can do this whenever you want to change hosts, anytime).

    resty http://127.0.0.1/data

 * Make some HTTP requests.

    GET /blogs.json
    PUT /blogs/2.json '{"title": "updated post", "body": "This is the new."}'
    DELETE /blogs/2
    POST /blogs.json '{"title": "new post", "body": "This is the new new."}'

Options
-------

Anything after the required arguments (2 of them in the case of the GET and
DELETE methods, and 3 in the case of PUT and POST) are passed on to `curl`.

For example:

    GET /blogs.json -H "Range: items=1"

JSON Pretty-Printing
--------------------

The included `pp` script will pretty-print JSON for you. You just need to
install the JSON perl module from CPAN.
