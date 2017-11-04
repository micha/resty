#!/usr/bin/env perl -0007

if( $ARGV[0] eq '-h' || $ARGV[0] eq '--help') {
  print "pp: Pretty print json piped as stdin or provided as file argument.\n";
  exit;
}

use JSON;
while (<>) {
  print to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})."\n";
}

# about:
# was orignaly a one liner:
# perl -0007 -MJSON -ne'print to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})."\n"'
