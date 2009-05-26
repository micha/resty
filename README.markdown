Quick Start
===========

You have `curl`, right? Okay. 

      curl http://github.com/micha/resty/raw/master/resty > resty

Source the script before using it. (You can put this line in your `~/.bashrc`
file if you want, or just paste the contents of the `resty` script right in
there. Either way works.)

      . resty

Set the REST host to which you will be making your requests (you
can do this whenever you want to change hosts, anytime).

      resty http://127.0.0.1:8080/data

Make some HTTP requests.

      GET /blogs.json
      PUT /blogs/2.json '{"title" : "updated post", "body" : "This is the new."}'
      DELETE /blogs/2
      POST /blogs.json '{"title" : "new post", "body" : "This is the new new."}'

Usage
=====

      resty                             # prints the current request URI base
      resty <remote>                    # sets the base request URI
      GET <path> [curl opts]            # does the GET request 
      DELETE <path> [curl opts]         # does DELETE request 
      PUT <path> <data> [curl opts]     # does PUT request
      POST <path> <data> [curl opts]    # does POST request

Request URI Base
================

The request URI base is what the eventual URI to which the requests will be
made is based on. Specifically, it is a URI that may contain the `*` character
one or more times. The `*` will be replaced with the `path` parameter in the
`GET`, `POST`, `PUT`, or `DELETE` request as described above.

For example:

      resty 'http://127.0.0.1:8080/data*.json'

and then

      GET /5

would result in a `GET` request to the URI `http://127.0.0.1:8080/data/5.json`.

If no `*` character is specified when setting the base URI, it's just added
onto the end for you automatically.

POST/PUT Requests and Data
==========================

Normally you would probably want to provide the request body data right on
the command line like this:

      PUT /blogs/5.json '{"title" : "hello", "body" : "this is it"}'

But sometimes you will want to send the request body from a file instead. To
do that you can specify `@<file>` in place of the data, like this:

      PUT /blogs/5.json @/tmp/t

Also, you can pipe the data in via stdin, if you want to, by replacing the
filename with `-`, like this:

      PUT /blogs/5.json @- < /tmp/t

Or, interestingly, as a filter pipeline with 
[jsawk](http://github.com/micha/jsawk):

      GET /blogs/5.json | jsawk 'this.author="Bob Smith";this.tags.push("news")' | PUT /blogs/5.json @-

Errors and Output
=================

For successful 2xx responses, the response body is printed on stdout. You
can pipe the output to stuff, process it, and then pipe it back to resty,
if you want.

For responses other than 2xx most HTTP servers will include HTML in the
response body describing what went wrong.  Resty will process the HTML with
`html2text` (if available), and dump it to stderr. If the response was not
HTML it should pass right through `html2text`, hopefully unmolested.

Options
=======

Anything after the required arguments is passed on to `curl`.

For example:

      GET /blogs.json -H "Range: items=1"

The `-H "Range: items=1"` argument will be passed to `curl` for you. This
makes it possible to do some more complex operations when necessary.

Here are some useful options to try:

  * **-v** verbose output, shows HTTP headers and status on stderr
  * **-u \<username:password\>** HTTP basic authentication
  * **-H \<header\>** add request header (this option can be added more than 
    once)

Exit Status
===========

Successful requests (HTTP respose with 2xx status) return zero.
Otherwise, the first digit of the response status is returned (i.e., 1 for
1xx, 3 for 3xx, 4 for 4xx, etc.) This is because the exit status is an 8 bit
integer---it can't be greater than 254. If you want the exact status code
you can always just pass the `-v` option to curl.

Working With JSON
=================

JSON REST web services require some special tools to make them accessible
and easily manipulated in the shell environment. The following are a few
scripts that make dealing with JSON data easier.

  * [Jsawk](http://github.com/micha/jsawk) can be used to process and filter
    JSON data from and to resty, in a shell pipeline. This takes care of
    parsing the input JSON correctly, rather than using regexes and sed,
    awk, perl or the like, and prints the resulting output in correct JSON
    format, as well.

    `GET /blogs.json |jsawk -n 'out(this.title)' # prints all the blog titles`

  * The included `pp` script will pretty-print JSON for you. You just need to
    install the JSON perl module from CPAN.

    `GET /blogs.json |pp # pretty-prints the JSON output from resty`
