Resty
=====

[![GitHub release](https://img.shields.io/github/release/micha/resty.svg)](https://github.com/micha/resty/releases)
[![Build Status](https://travis-ci.org/AdrieanKhisbe/resty.svg?branch=master)](https://travis-ci.org/AdrieanKhisbe/resty)
[![GitHub license](https://img.shields.io/github/license/micha/resty.svg)](https://github.com/micha/resty/blob/master/MIT-LICENSE.txt)

> **Resty** is a *tiny* script wrapper for [curl](http://curl.haxx.se/).

It provides a simple, concise shell interface for interacting with
[REST](http://en.wikipedia.org/wiki/Representational_State_Transfer) services.
Since it is implemented as functions in your shell and not in its own separate
command environment you have access to all the powerful shell tools, such
as `perl`, `awk`, `grep`, `sed`, etc. You can use resty in pipelines to process data
from `REST` services, and `PUT`, `PATCH`, or `POST` the data right back.  You can even pipe
the data in and then edit it interactively in your text editor prior to `PUT`,
`PATCH`, or `POST`.

Cookies are supported automatically and stored in a file locally. Most of
the arguments are remembered from one call to the next to save typing. It
has pretty good defaults for most purposes. Additionally, **resty** allows you
to easily provide your own options to be passed directly to `curl`, so even
the most complex requests can be accomplished with the minimum amount of
command line pain.

[Here is a nice screencast showing resty in action](http://jpmens.net/2010/04/26/resty/) (by Jan-Piet Mens).

## Quick Start

You have `curl`, right? Okay.

      $ curl -L https://raw.githubusercontent.com/micha/resty/master/resty > resty

Source the script before using it.

      $ . resty

Once **resty** is installed, set your REST host to which you will be making your requests.

      $ resty http://127.0.0.1:8080/data
      http://127.0.0.1:8080/data*

And now you can Make some HTTP requests.

      $ GET /blogs.json
      [ {"id" : 1, "title" : "first post", "body" : "This is the first post"}, ... ]

      $ PUT /blogs/2.json '{"id" : 2, "title" : "updated post", "body" : "This is the new."}'
      {"id" : 2, "title" : "updated post", "body" : "This is the new."}

      $ DELETE /blogs/2

      $ POST /blogs.json '{"title" : "new post", "body" : "This is the new new."}'
      {"id" : 204, "title" : "new post", "body" : "This is the new new."}

## Installation

There are several way to install **resty** other than `curl`ing it and sourcing it.

Here are some shell package manager that are supported:

- **Bpkg** : with [`bpkg`](http://www.bpkg.sh/) installed just run `bpkg install -g micha/resty`,
   then follow the instruction by adding `source ~/.bashrc.d/resty` to your `bashrc`
- **Antigen** : with [`antigen`](https://github.com/zsh-users/antigen) for zsh, just add `antigen bundle micha/resty` in your `.zshrc`
- **Zplug**: with [`zplug`](https://github.com/zplug/zplug) installed, just add `zplug micha/resty, use:'resty'` in your `.zshrc`
- **Oh my Zsh**: clone the github repositery in the `plugins` directory of `ZSH_CUSTOM` and add `resty` to you `plugins` list


## Usage

      source resty [-W] [remote] [OPTIONS]    # load functions into shell
      resty [-v]                              # prints current request URI base
      resty <remote> [OPTIONS]                # sets the base request URI

      HEAD [path] [OPTIONS]                   # HEAD request
      OPTIONS [path] [OPTIONS]                # OPTIONS request
      GET [path] [OPTIONS]                    # GET request
      DELETE [path] [OPTIONS]                 # DELETE request
      PUT [path] [data] [OPTIONS]             # PUT request
      PATCH [path] [data] [OPTIONS]           # PATCH request
      POST [path] [data] [OPTIONS]            # POST request
      TRACE [path] [OPTIONS]                  # TRACE request

      Options:

      -Q            Don't URL encode the path.
      -q <query>    Send query string with the path. A '?' is prepended to
                    <query> and concatenated onto the <path>.
      -W            Don't write to history file (only when sourcing script).
      -V            Edit the input data interactively in 'vi'. (PUT, PATCH,
                    and POST requests only, with data piped to stdin.)
      -Z            Raw output. This disables any processing of HTML in the
                    response.
      -v            Verbose output. When used with the resty command itself
                    this prints the saved curl options along with the current
                    URI base. Otherwise this is passed to curl for verbose
                    curl output.
      --dry-run     Just output the curl command.
      <curl opt>    Any curl options will be passed down to curl.

## Configuration, Data File Locations


Resty creates a few files in either your `${XDG_CONFIG_HOME}` and `${XDG_DATA_HOME}`
directory (if your linux uses the XDG directory standard) or in the `~/.resty`
directory, otherwise.

#### Using Existing, Pre-v2.1 Configuration Files With v2.1 ####

If you had resty installed before version 2.1 and your system uses the XDG
config directory standard and you want to continue using your existing
configuration files, please make a backup of your `~/.resty` directory
and then do:

      $ mkdir -p "${XDG_CONFIG_HOME}/resty" "${XDG_DATA_HOME}/resty"
      $ mv ~/.resty/c "${XDG_DATA_HOME}/resty"
      $ mv ~/.resty/* "${XDG_CONFIG_HOME}/resty"

## Request URI Base

The request URI base is what the eventual URI to which the requests will be
made is based on. Specifically, it is a URI that may contain the `*` character
one or more times. The `*` will be replaced with the `path` parameter in the
`OPTIONS`, `HEAD`, `GET`, `POST`, `PUT`, `PATCH`, or `DELETE` request as described
above.

For example:

      $ resty 'http://127.0.0.1:8080/data*.json'
      http://127.0.0.1:8080/data*.json

and then

      $ GET /5
      { "the_response" : true }

would result in a `GET` request to the URI `http://127.0.0.1:8080/data/5.json`.

If no `*` character is specified when setting the base URI, it's just added
onto the end for you automatically.

### HTTPS URIs

HTTPS URIs can be used, as well. For example:

      $ resty 'https://example.com/doit'
      https://example.com/doit*

### URI Base History

The URI base is saved to an rc file (`${XDG_CONFIG_HOME}/resty/host` or `~/.resty/host`)
each time it's set, and the last setting is saved in an environment variable
(`$_resty_host`).  The URI base is read from the rc file when resty starts
up, but only if the `$_resty_host` environment variable is not set.
In this way you can make requests to different hosts using resty from
separate terminals, and have a different URI base for each terminal.

If you want to see what the current URI base is, just run `resty` with no
arguments. The URI base will be printed to stdout.

## The Optional Path Parameter

The HTTP verbs (`OPTIONS`, `HEAD`, `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`)
first argument is always an optional URI path. This path must always start with a
`/` character. If the path parameter is not provided on the command line, resty
will just use the last path it was provided with. This "last path" is stored in an
environment variable (`$_RESTY_PATH`), so each terminal basically has its
own "last path".

This feature can be disabled with the following flag `RESTY_NO_PRESERVE_PATH=true`.

### URL Encoding Of Path Parameter

Resty will always [URL encode]
(http://www.blooberry.com/indexdot/html/topics/urlencoding.htm) the path,
except for slashes. (Slashes in path elements need to be manually encoded as
`%2F`.) This means that the `?`, `=`, and `&` characters will be encoded, as
well as some other problematic characters. To disable this behavior use the
`-Q` option.

### Query Strings, POST Parameters, And Both At The Same Time


There are three ways to add a query string to the path. The first, mentioned
above, is to disable URL encoding with the `-Q` option, and include the
query string with the path parameter, like this:

      $ GET '/blogs/47?param=foo&otherparam=bar' -Q

To specify a query string without disabling URL encoding on the path the
`-q` option is used, like this:

      $ GET /blogs/47 -q 'param=foo&otherparam=bar'

Finally, you can use the curl `-d` and `-G` options, like this:

      $ GET /blogs/47 -d 'param=foo' -d 'otherparam=bar' -G

However, if you want to pass both GET parameters in the query string _and_
`POST` parameters in the request body, curl cannot support this by itself.
Using the `-q` or `-Q` resty options with the `-d` curl option will accomplish
this, like so:

      $ POST '/blogs/47?param=foo&otherparam=bar' -Q -d 'postparam=baz'

## POST/PUT/PATCH Requests and Data

Normally you would probably want to provide the request body data right on
the command line like this:

      $ PUT /blogs/5.json '{"title" : "hello", "body" : "this is it"}'

But sometimes you will want to send the request body from a file instead. To
do that you pipe in the contents of the file:

      $ PUT /blogs/5.json < /tmp/t

Or you can pipe the data from another program, like this:

      $ myprog | PUT /blogs/5.json

Or, interestingly, as a filter pipeline with
[jsawk](http://github.com/micha/jsawk):

      $ GET /blogs/5.json | jsawk 'this.author="Bob Smith";this.tags.push("news")' | PUT

Notice how the `path` argument is omitted from the `PUT` command.

### Edit PUT/PATCH/POST Data In Vi

With the `-V` options you can pipe data into `PUT`, `PATCH`, or `POST`, edit
it in vi, save the data (using `:wq` in vi, as normal) and the resulting data
is then PUT, PATCH, or POSTed. This is similar to the way `visudo` works, for example.

      $ GET /blogs/2 | PUT -V

This fetches the data and lets you edit it, and then does a PUT on the
resource. If you don't like vi you can specify your preferred editor by
setting the `EDITOR` environment variable.

## Errors and Output

For successful *2xx* responses, the response body is printed on stdout. You
can pipe the output to stuff, process it, and then pipe it back to resty,
if you want.

For responses other than *2xx* the response body is dumped to stderr.

In either case, if the content type of the response is `text/html`, then
resty will try to process the response through either `lynx`, `html2text`,
or, finally, `cat`, depending on which of those programs are available on
your system.

### Raw Output (-Z option)

If you don't want resty to process the output through lynx or html2text you
can use the `-Z` option, and get the raw output.

## Passing Command Line Options To Curl

Anything after the (optional) `path` and `data` arguments is passed on to
`curl`.

For example:

      $ GET /blogs.json -H "Range: items=1-10"

The `-H "Range: items=1-10"` argument will be passed to `curl` for you. This
makes it possible to do some more complex operations when necessary.

      $ POST -v -u user:test

In this example the `path` and `data` arguments were left off, but `-v` and
`-u user:test` will be passed through to `curl`, as you would expect.

Here are some useful options to try:

  - **-v** verbose output, shows HTTP headers and status on stderr
  - **-j** junk session cookies (refresh cookie-based session)
  - **-u \<username:password\>** HTTP basic authentication
  - **-H \<header\>** add request header (this option can be added more than
    once)

### Setting The Default Curl Options

Sometimes you want to send some options to curl for every request. It
would be tedious to have to repeat these options constantly. To tell
*resty* to always add certain curl options you can specify those options
when you call resty to set the URI base. For example:

      $ resty example.com:8080 -H "Accept: application/json" -u user:pass

Every subsequent request will have the `-H "Accept:..."` and `-u user:...`
options automatically added. Each time resty is called this option list
is reset.

### Per-Host/Per-Method Curl Configuration Files

*Resty* supports a *per-host/per-method configuration* file to help you with
frequently used curl options. Each host (including the port) can have its
own configuration file in the `~/.resty` directory.
A special host `resty` is used to define *default* options for all the hosts.

The file format is

      GET [arg] [arg] ...
      PUT [arg] [arg] ...
      PATCH [arg] [arg] ...
      POST [arg] [arg] ...
      DELETE [arg] [arg] ...

Where the `arg`s are curl command line arguments. Each line can specify
arguments for that HTTP verb only, and all lines are optional.

These config files are loaded each time you run the `resty` command.

#### Example
So, suppose you find yourself using the same curl options over and over. You
can save them in a file and resty will pass them to curl for you. Say this
is a frequent pattern for you:

      $ resty localhost:8080
      $ GET /Blah -H "Accept: application/json"
      $ GET /Other -H "Accept: application/json"
      ...
      $ POST /Something -H "Content-Type: text/plain" -u user:pass
      $ POST /SomethingElse -H "Content-Type: text/plain" -u user:pass
      ...

It's annoying to add the `-H` and `-u` options to curl all the time. So
create a file `~/.resty/localhost:8080`, like this:

_~/.resty/localhost:8080_

      GET -H "Accept: application/json"
      POST -H "Content-Type: text/plain" -u user:pass

Then any `GET` or `POST` requests to `localhost:8080` will have the specified
options prepended to the curl command line arguments, saving you from having
to type them out each time, like this:

      $ GET /Blah
      $ GET /Other
      ...
      $ POST /Something
      $ POST /SomethingElse
      ...

Sweet! Much better.

## Exit Status

Successful requests (HTTP respose with *2xx* status) return zero.
Otherwise, the first digit of the response status is returned (i.e., 1 for
1xx, 3 for 3xx, 4 for 4xx, etc.) This is because the exit status is an 8 bit
integer---it can't be greater than 255. If you want the exact status code
you can always just pass the `-v` option to curl.

## Using Resty In Shell Scripts

Since resty creates the REST verb functions in the shell, when using it from a script you must `source` it before you use any of the functions. However, it's likely that you don't want it to be overwriting the resty host history file, and you will almost always want to set the URI base explicitly.

      #!/usr/bin/env bash

      # Load resty, don't write to the history file, and set the URI base
      . /path/to/resty -W 'https://myhost.com/data*.json'

      # GET the JSON list of users, set each of their 'disabled' properties
      # to 'false', and PUT the modified JSON back
      GET /users | jsawk 'this.disabled = false' | PUT

Here the `-W` option was used when loading the script to prevent writing to the history file and an initial URI base was set at the same time. Then a JSON file was fetched, edited using [jsawk](http://github.com/micha/jsawk), and re-uploaded to the server.

To assign the response of resty to a variable you can you do for example: `VAR="$(GET /some/request)"`. Note that the quote symbol (`"`) around the subcommand is necessary if the output contains spaces.

## Working With JSON or XML Data

`JSON REST` web services require some special tools to make them accessible
and easily manipulated in the shell environment. The following are a few
scripts that make dealing with JSON data easier.

  * The included `pp` script will pretty-print JSON for you. You just need to
    install the JSON perl module from CPAN (included with brew install)
    or you can use `pypp` if you have python installed.

    `GET /blogs.json | pp   # pretty-prints the JSON output from resty`

  * You can use powerful [jq](https://stedolan.github.io/jq/) Json command line
    processor to perform operations on the received json. just pyping to `jq .`
    will pretty print the json in color

  * Another way to format JSON output:

        $ echo '{"json":"obj"}' | python -mjson.tool
        {
          "json": "obj"
        }

  * [Jsawk](http://github.com/micha/jsawk) can be used to process and filter
    JSON data from and to resty, in a shell pipeline. This takes care of
    parsing the input JSON correctly, rather than using regexes and `sed`,
    `awk`, `per`l or the like, and prints the resulting output in correct JSON
    format, as well.

    `GET /blogs.json | jsawk -n 'out(this.title)' # prints all the blog titles`


  * The `tidy` tool can be used to format HTML/XML:

        $ ~$ echo "<test><deep>value</deep></test>" | tidy -xml -q -i
        <test>
          <deep>value</deep>
        </test>
