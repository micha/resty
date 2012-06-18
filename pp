perl -0007 -MJSON -ne'eval { print to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})."\n"; 1 } || print "$_\n"'
