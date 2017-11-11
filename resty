#  -*-  mode: sh -*-
# resty - A tiny command line REST interface for bash and zsh.
#
# Fork me on github:
#   http://github.com/micha/resty
#
# Author:
#   Micha Niskin <micha@thinkminimo.com>
#   Copyright 2009-2017, MIT licence.
#
# Maintener:
#   Adriean Khisbe <adriean.khisbe@live.fr>
#


export _RESTY_HOST=""
export _RESTY_PATH=""
export _RESTY_NO_HISTORY=""
export _RESTY_H2T="$( (exec 2>&-; (which lynx >/dev/null && echo "lynx -stdin -dump") \
			  || which html2text || which cat) |tail -n 1)"
export _RESTY_EDITOR=$( (exec 2>&-; which "$EDITOR" || which vim || echo "vi") |tail -n 1)    # editor default

export _RESTY_DATA_DIR _RESTY_CONF_DIR


function resty() {

    local url; url="$1"; [ -n "$1" ] && shift
    if [ -n "$url" ] && [[ "HEAD OPTIONS GET PATCH POST PUT TRACE DELETE" =~ $url ]] ; then
        resty-call $url "$@"
        return
    fi

    local args j; args=() j=1
    for i in "$@"; do
        args[j]="$i" && j=$((j + 1))
        if [[ $i =~ ^-h\|--help$ ]] ; then
            cat <<HELP
resty [host] [options]:

      Set the host and default options to provided values
HELP
            -resty-help-options
            return 0
        fi
    done

    if [ -n "$XDG_CONFIG_HOME" ]; then
        _RESTY_CONF_DIR="$XDG_CONFIG_HOME/resty"
        _RESTY_DATA_DIR="$XDG_DATA_HOME/resty"
    else
        _RESTY_CONF_DIR="$HOME/.resty"
        _RESTY_DATA_DIR="$_RESTY_CONF_DIR"
    fi
    mkdir -p "$_RESTY_CONF_DIR"

    local host; host="$_RESTY_DATA_DIR/host"

    case "$url" in
	http://*|https://*)
	    if [ "${#args[@]}" -ne 0 ]; then _RESTY_OPTS=$(printf "%q " "${args[@]}"|sed 's:[[:space:]]*$::'); else _RESTY_OPTS=""; fi
	    export _RESTY_OPTS
	    echo "$url" |grep '\*' >/dev/null || url="${url}*"
	    (echo "$url" |tee "${_RESTY_NO_HISTORY:-$host}") |cat 1>&2 \
		&& export _RESTY_HOST="$url"
	    ;;
	*)
	    resty "http://$url" "${args[@]}"
	    return
	    ;;
    esac

    resty-compute-host-option
}

function resty-compute-host-option () {
    # note: extract a function so it can be manually called if edited file
    local domain; domain=$(echo -n "$_RESTY_HOST" | perl -ane '/^https?:\/\/([^\/\*]+)/; print $1')
    if [[ -f "$_RESTY_CONF_DIR/resty" ]] ; then
        for method in HEAD OPTIONS GET PATCH POST PUT TRACE DELETE ; do
            eval "export _RESTY_OPT_DEFAULT_$method; _RESTY_OPT_DEFAULT_$method=\"$(cat "$_RESTY_CONF_DIR/resty" 2>/dev/null\
                          | sed 's/^ *//' \
                          | grep "^$method" | cut -b $((${#method}+2))-)\""
        done
    else
        for method in HEAD OPTIONS GET PATCH POST PUT TRACE DELETE ; do
            eval "export _RESTY_OPT_DEFAULT_$method; _RESTY_OPT_DEFAULT_$method=\"\""
        done
    fi
    if [[ -f "$_RESTY_CONF_DIR/$domain" ]] ; then
        for method in HEAD OPTIONS GET PATCH POST PUT TRACE DELETE ; do
            eval "export _RESTY_OPT_HOST_$method; _RESTY_OPT_HOST_$method=\"$(cat "$_RESTY_CONF_DIR/$domain" 2>/dev/null\
                        | sed 's/^ *//' \
                        | grep "^$method" | cut -b $((${#method}+2))-)\""
        done
    else
        for method in HEAD OPTIONS GET PATCH POST PUT TRACE DELETE ; do
           eval "export _RESTY_OPT_HOST_$method; _RESTY_OPT_HOST_$method=''"
        done
    fi
}

function resty-call() {
    if [ $# = 0 ] ; then echo "resty-call need args" >&2; return 1; fi

    local method; method="$1"; shift
    if [[ ! "HEAD OPTIONS GET PATCH POST PUT TRACE DELETE" =~ $method ]] ; then # this is not good
        echo "First arg must be an HTTP verb, '$method' isn't" >&2
        return 1
    fi
    for opt in "$@"; do # print help if requested
        if [[ $opt =~ ^-h\|--help$ ]] ; then
            cat <<HELP
$method [path] [options]:

      Perform a $method request to host $_RESTY_HOST with path and options.
HELP
            -resty-help-options
            return 0
        fi
    done

    local _path __path

    local host="$_RESTY_DATA_DIR/host"
    local cookies="$_RESTY_DATA_DIR/c"

    local h2t="$_RESTY_H2T"
    local editor="$_RESTY_EDITOR"
    if [[ "POST PUT TRACE PATCH DELETE" =~ $method ]]; then local hasbody; hasbody="yes" ;fi

    if [ -d "$cookies" ] ; then # retrieve cookie
	    (mkdir -p "$cookies"; echo "http://localhost*" > "$host")
    fi

    if [[ "$1" =~ ^/ ]] ; then # retrieve path
        _path="$1"
        shift
    fi
    local body
    if [[ ! "$1" =~ ^- ]] ; then # retrieve data
         body="$1"
        [[ $# -gt 0 ]] && shift
    fi

    local -a all_opts curlopt_cmd
    local raw query vimedit quote maybe_query verbose dry_run

    local -a resty_default_arg host_arg;
    for i in $(eval echo "\${_RESTY_OPT_DEFAULT_$method}") ; do resty_default_arg+=("$i") ; done
    for i in $(eval echo "\${_RESTY_OPT_HOST_$method}") ; do host_arg+=("$i") ; done

    for opt in "$@"; do all_opts+=($(printf '%q' "$opt")) ; done
    all_opts+=("${resty_default_arg[@]}")
    all_opts+=("${host_arg[@]}")
    if [ "${#_RESTY_OPTS[@]}" -ne 0 ] ; then all_opts+=("${_RESTY_OPTS[@]}") ; fi

    for opt in "${all_opts[@]}"; do
        if [ -n "$maybe_query" ] && [ -z "$query" ] ; then query="?$opt"; continue; fi

        case $opt in
            --verbose|-v) verbose="yes";;
            # TODO; try adapt ; echo "$opt" | grep '^-[a-zA-Z]*v[a-zA-Z]*$' >/dev/null) \
            -V) vimedit="yes" ;;
            -Z) raw="yes" ;;
            -W) ;;
            -Q) quote="yes" ;;
            -q) maybe_query="yes" ;;
            --dry-run) dry_run="yes";;
            --json) curlopt_cmd+=("-H 'Accept: application/json'" "-H 'Content-Type: application/json'") ;;
            --xml) curlopt_cmd+=("-H 'Accept: application/xml'" "-H 'Content-Type: application/xml'") ;;
            *) curlopt_cmd+=("$opt")
        esac
    done

    if [ -z "$quote" ]; then # replace special char with codes
	    _path=$(echo "$_path"|sed 's/%/%25/g;s/\[/%5B/g;s/\]/%5D/g;s/|/%7C/g;s/\$/%24/g;s/&/%26/g;s/+/%2B/g;s/,/%2C/g;s/:/%3A/g;s/;/%3B/g;s/=/%3D/g;s/?/%3F/g;s/@/%40/g;s/ /%20/g;s/#/%23/g;s/{/%7B/g;s/}/%7D/g;s/\\/%5C/g;s/\^/%5E/g;s/~/%7E/g;s/`/%60/g')
    fi

    if [ -z "$_RESTY_HOST" ] ;then _RESTY_HOST=$(cat "$host" 2>/dev/null);fi

    if [ "$RESTY_NO_PRESERVE_PATH" != "true" ]&&[ "$RESTY_NO_PRESERVE_PATH" != "yes" ]; then
        __path="${_path:-${_RESTY_PATH}}"
        _RESTY_PATH="${__path}"
    else
        __path=$_path
    fi

    local domain; domain=$(echo -n "$_RESTY_HOST" | perl -ane '/^https?:\/\/([^\/\*]+)/; print $1')
    _path="${_RESTY_HOST//\*/$__path}"

    if [ "$hasbody" = "yes" ] && [ -z "$body" ]; then # treat when no body provided as arg
        if [ ! -t 0 ] ; then # retrieve what stdin hold if stdin open
           body="@-"
        else
           body=""
        fi
    fi

    if [ "$hasbody" = "yes" ] && [ "$vimedit" = "yes" ]; then
        local tmpf; tmpf=$(mktemp)
        [ -t 0 ] || cat > "$tmpf"
        (exec < /dev/tty; "$editor" "$tmpf")
        body=$(cat "$tmpf")
        rm -f "$tmpf"
    fi

    if [ -n "$body" ] ; then curl_opt="--data-binary" ;fi
    if [ "$method" = "OPTIONS" ] ; then raw="yes" ; fi
    if [ "$method" = "HEAD" ] ; then
        curl_opt="-I"
        raw="yes"
    fi

    # Forge command and display it if dry-run
    local cmd
    cmd=(curl -sLv $curl_opt $(printf "%q" "$body") -X $method  -b \"$cookies/$domain\" -c \"$cookies/$domain\" "$(\
        [ -n "$curlopt_cmd" ] && printf '%s ' ${curlopt_cmd[@]})"\"$_path$query\")
    if [ "$dry_run" = "yes" ] ; then
        echo "${cmd[@]}"
        return 0
    fi

    # Launch command and retrieved streams
    local res out err ret _status outf errf
    outf=$(mktemp) errf=$(mktemp)
    eval "${cmd[@]}" > "$outf" 2> "$errf"
    _status=$?; out="$(cat "$outf")"; err="$(cat "$errf")"; rm -f "$outf" "$errf"
    ret=$(sed '/^.*HTTP\/1\.[01] [0-9][0-9][0-9]/s/.*\([0-9]\)[0-9][0-9].*/\1/p; d' <<< "$err" | tail -n1)

    if [ "$_status" -ne "0" ]; then echo "$err" >&2 ; return $_status ; fi

    if [ -n "$err" ] && [ -n "$verbose" ]; then echo "$err" 1>&2 ; fi

    # post process for display
    local display
    if [ -z "$raw" ] && grep -i '^< \s*Content-Type:  *text/html' >/dev/null <<< "$err"
    then display=$h2t
    else display=cat
    fi
    if [ -n "$out" ]; then out=$(echo "$out" | eval "$display") ; fi

    if [[ "$display" =~ ^lynx ]] || [[ "$display" =~ ^elinks ]] ; then
        out=$(echo "$out" |perl -e "\$host='$(echo "$_RESTY_HOST" |sed 's/^\(https*:\/\/[^\/*]*\).*$/\1/')';" \
                                -e "$(cat <<'PERL'
            @a=<>;
            $s=0;
            foreach (reverse(@a)) {
                if ($_ =~ /^References$/) { $s++; }
                unless ($s>0) {
                    s/^\s+[0-9]+\. //;
                    s/^file:\/\/localhost/$host/;
                }
                push(@ret,$_);
            }
            print(join("",reverse(@ret)))
PERL
            )")
    fi

    if [ "$ret" != "2" ]; then
        [ -n "$out" ] && echo "$out" 1>&2
        return $ret
    else
        [ -n "$out" ] && echo "$out"
        return 0
    fi

}

function resty-load-alias(){
    alias HEAD=resty-head OPTIONS=resty-options GET=resty-get POST=resty-post PUT=resty-put
    alias TRACE=resty-trace PATCH=resty-patch DELETE=resty-delete
    # maybe add option?
}

resty-load-alias # Loaded by default. §maybe: Latter do an option (opt-in or opt-out)

function resty-unload-alias(){
    unalias HEAD OPTIONS GET POST PUT TRACE PATCH DELETE
}

function resty-head() {
    resty-call HEAD "$@"
}

function resty-options() {
    resty-call OPTIONS "$@"
}

function resty-get() {
    resty-call GET "$@"
}

function resty-post() {
    resty-call POST "$@"
}

function resty-put() {
    resty-call PUT "$@"
}

function resty-patch() {
    resty-call PATCH "$@"
}

function resty-delete() {
    resty-call DELETE "$@"
}

function resty-trace() {
    resty-call TRACE "$@"
}

function -resty-help-options () {
cat <<HELP

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
HELP
}

# With -W option, does not write to history file
[ "$1" = "-W" ] && export _RESTY_NO_HISTORY="/dev/null" && [[ $# -gt 0 ]] && shift

resty "$@" >/dev/null 2>&1
