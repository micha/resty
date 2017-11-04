#!/usr/bin/env perl -0007

use JSON;
while (<>) {
  print to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})."\n";
}

# about:
# was orignaly a one liner:
# perl -0007 -MJSON -ne'print to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})."\n"'
