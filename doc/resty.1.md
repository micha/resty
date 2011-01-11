resty(1) -- command line REST client
====================================

## SYNOPSIS

`source` `resty` [`-W`] [<remote>]<br>
`resty` [<remote>]<br>
`HEAD` [<path>] [[curl options]]<br>
`OPTIONS` [<path>] [[curl options]]<br>
`GET` [<path>] [`-Z`] [[curl options]]<br>
`DELETE` [<path>] [`-Z`] [[curl options]]<br>
`PUT` [<path>] [<data>`|-V`] [`-Z`] [[curl options]]<br>
`POST` [<path>] [<data>`|-V`] [`-Z`] [[curl options]]<br>
`TRACE` [<path>] [<data>`|-V`] [`-Z`] [[curl options]]<br>

## DESCRIPTION

**Resty** is a command line REST client for the bash(1) or zsh(1)
shell. It is implemented as functions in the shell, and can be used in 
pipelines with sed(1), awk(1), grep(1), etc.

The **resty** script contains the definitions for the **resty** function and 
functions for each of the REST verbs: HEAD, OPTIONS, GET, DELETE, PUT, POST,
and TRACE. This script must be sourced from the shell before the functions can
be used.

The **resty** function is used to get or set the URI base, as described below
under [REQUEST URI BASE]. When no <remote> argument is specified, the URI base
is printed to stdout. Otherwise, a new request URI base is set to <remote>, and
the resulting URI base is printed to stdout.

The REST verb functions are used to make HTTP requests. For PUT and POST
requests data can be provided on the command line, stdin, or from a text editor.
Response data is printed to stdout.

## OPTIONS

This option is used when sourcing the **resty** script, not with the
**resty** or HTTP verb functions.

  * `-W`:
    Don't write history file. This is handy when using **resty** in scripts,
    where the URI history file is not relevant.

These options are used with the **resty** and HTTP verb functions. They control
how data is provided to HTTP requests, and how responses are formatted in the
terminal.

  * `-V`:
    Edit PUT/POST data interactively in a text editor. The editor used will be
    the one in the EDITOR environment variable, or vim(1) otherwise.

  * `-Z`:
    Don't process HTML response with lynx(1) or html2text(1), just send the raw
    response to stdout.

## CURL OPTIONS

Options other than those listed above under [OPTIONS] are passed directly to
**curl**.

## REQUEST URI BASE

The request URI base is a template for the URIs to which requests will be made.
It is a URI that may contain the `*` character (possibly more than once). Each
instance of `*` is replaced with the <path> parameter in the HTTP request.

If the protocol part of the URI is omitted when setting the URI base, the
default `http` is used. Also, if no `*` is present one is appended to the end
of the URI by default.

### URI Base History

The URI base is saved to a text file (*~/.resty/host*) each time it is set,
and the last setting is saved in an environment variable (`$_resty_host`). The
**resty** function checks to determine whether the environment variable is set.
If it is not, it reads the text file and sets the URI base accordingly. In this
way each shell maintains its own URI base.

## PATH PARAMETER

The HTTP verb functions' first (optional) parameter is the <path>. The <path>
must always start with a `/` character. The <path> is substituted for each
instance of `*` in the URI base when a request is made.

### Path History

If no <path> is specified, then the last <path> specified will be used. This
"last path" is stored in the `$_resty_path` environment variable.

### Path URL Encoding & Query Strings

**Resty** encodes the path, except for the `/` character (`/` must be manually
encoded, eg. `%2F`). Since this means that `?`, `=`, and `&` characters will
be URL encoded, as well as some other problematic characters, curl options
must be used to send query parameters in requests. The `-d` and `-G` curl 
options provide this functionality.

## RESPONSE BODY

The body of the HTTP response is printed to stdout for all successful (HTTP 2xx
status) requests. The body of all other responses is dumped to stderr.

In either case, if the content-type of the response is `text/html` **resty**
will attempt to filter the response body through one of lynx(1), html2text(1),
or cat(1), in that order. This behavior can be disabled with the `-Z` option
to get the raw response body.

## EXIT STATUS

Successful requests (HTTP 2xx response status) exit with a status of zero.
Otherwise, the first digit of the HTTP response status is returned. The `-v`
curl option is available when the exact status is required.

## PER-HOST, PER-METHOD CONFIGURATION FILES

**Resty** supports per-host, per-method configuration files to help with
frequently used curl options. Each host (optionally including the port) may
have its own configuration file in the *~/.resty* directory. Each line of the
file consists of an HTTP method followed by a number of curl options, exactly
as they would appear on the command line.

Then, when a request is made, **resty** checks to see if there is a config
file named for that host/port. If there is one, it then checks the file to
find the line corresponding to the request method. If such a line exists
then the rest of the line is passed to curl as options.

  * `Ex:`:
    Sometimes the server setup requires curl options to be specified on
    every request. This can get to be extremely cumbersome and tedious
    after a while. Suppose your case requires many requests of this form:

    $ resty example.com:8080<br>
    http://example.com:8080*<br>
    $ GET / -H 'Accept:application/json' -u mylogin:secretpasswd<br>
    ... response ...<br>
    $ DELETE /other/path/ -H 'Accept:application/json' -u mylogin:secretpasswd<br>
    ... response ...<br>

    By making a per-host configuration file in your *~/.resty/* directory
    you can have these boilerplate options added automatically for each
    request. Create the file *~/.resty/example.com:8080* with the following
    contents:

    GET -H 'Accept:application/json' -u mylogin:secretpasswd<br>
    DELETE -H 'Accept:application/json' -u mylogin:secretpasswd<br>

    Now all GET and DELETE requests to this host and port will have those
    options automatically applied.

## EXAMPLES

Here are a few examples to get things started. First, a simple, common case.
The first command loads the resty functions into the shell:

    $ . resty

Then the request URI base is set:

    $ resty example.com
    http://example.com*

Next, a GET request is made on http://example.com/, and the response body
is printed (response body HTML processed by lynx):

    $ GET /
                                Hello, World!

      This is a test!

Here the same URI is fetched with another GET request, but this time the
raw response body printed:

    $ GET / -Z
    <html>
      <body>
        <h1>Hello, World!</h1>
        <p>This is a test.</p>
      </body>
    </html>
    
You can also use "pipelines" to filter resources. Here a notional RESTful
database is queried, and a record updated:

    $ GET /data/1
    { "id" : 1, "foo" : "bar" }
    $ GET /data/1 | sed 's/bar/baz/' | PUT
    { "id" : 1, "foo" : "baz" }

Notice how the PUT command did not require a <path> parameter. The <path>
simply defaults to the last used <path>, which in this case is '/data/1'.

Here a new record is added with a POST request:

    $ POST /data/ '{ "foo" : "bar" }'
    { "id" : 13, "foo" : "bar" }

Or POST using data piped to stdin:

    $ GET /data/13 | sed 's/bar/baz/' | POST /data/
    { "id" : 42, "foo" : "baz" }

Or the record could be crafted using a text editor:

    $ GET /data/13 | POST /data -V
    ... edit /data/13 in vim ...
    { "id" : 43, "foo" : "baf" }

Query strings are escaped in the <path> parameter, so curl options are used:

    $ GET /data/1 -d arg1=foo -d arg2=bar -G

HTTP basic authentication (`-u` curl option):

    $ POST /data/ -u user:pass < datafile

See the headers on stderr with the request body on stdout (`-v` curl option):
 
    $ GET / -v
    * About to connect() to example.com port 80 (#0)
    *   Trying 192.168.5.101... connected
    * Connected to thinkminimo.com (192.168.5.101) port 80 (#0)
    > GET / HTTP/1.1
    > User-Agent: curl/7.21.0 (x86_64-apple-darwin10.2.0) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.5 libidn/1.19
    > Host: example.com:80
    > Accept:a #0 to host example.com left intact
    * Closing connection #0
                                Hello, World!

      This is a test.

## FILES

  * `~/.resty/`:
    Directory containing **resty** configuration files.

  * `~/.resty/host`:
    Request URI base history file.

  * `~/.resty/c`:
    Cookie storage directory.

  * `~/.resty/<host>[:<port>]`:
    Per-host options configuration files.

## ENVIRONMENT

  * `_resty_host`:
    Last setting for request URI base.

  * `_resty_path`:
    Last request <path> parameter. Used when no <path> parameter is specified.

  * `EDITOR`:
    Used to determine which text editor to use for editing PUT/POST request
    body.

## BUGS

Please report bugs here: <http://github.com/micha/resty/issues>.

## COPYRIGHT

Copyright (C) 2009 Micha Niskin <http://github.com/micha>, no rights reserved.

## SEE ALSO

awk(1), bash(1), cat(1), grep(1), html2text(1), lynx(1), sed(1), vim(1), zsh(1)
