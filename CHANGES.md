Resty CHANGES
=============

### Version 1.5 (2011-03-20)

* Curl options can now be specified when calling the resty command to set
  the URI base. These options will be passed to curl for all subsequent
  requests, until the next time the resty command is called.

### Version 1.4 (2011-03-08)

* Finalized bug fix for zsh users.

### Version 1.3 (2011-03-04)

* Attempted bug fix for zsh users that prevented options from being passed
  correctly to curl.

### Version 1.2 (2011-02-06)

* Data is now optional in PUT and POST requests. If the input is not a
  terminal and no data is specified on the command line, resty won't wait
  for data on stdin anymore. If you liked the old behavior you can always do
  something like `cat | POST /Somewhere` for the same effect.

### Version 1.1 (2011-01-07)

* Fixed bug where -V option required input on stdin, and would block waiting
  for it.
