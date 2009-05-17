perl -0007 -MJSON -nE'say to_json(from_json($_, {allow_nonref=>1}),{pretty=>1})'
