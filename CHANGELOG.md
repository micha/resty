# Change Log
All notable changes to *Resty* will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Changed

- major refactor
### Fixed
- Documentation glitch

## History Black Hole to retrieve

<!-- TODO: Patch release and 1 to 2 -->

## [1.5] - 2011-03-20
### Added
- Curl options can now be specified when calling the resty command to set
  the URI base. These options will be passed to curl for all subsequent
  requests, until the next time the resty command is called.

## [1.4] - 2011-03-08
### Fixed
- several bugs fix for zsh users.

## [1.3] - 2011-03-04

* Attempted bug fix for zsh users that prevented options from being passed
  correctly to curl.

## [1.2] - 2011-02-06 -

* Data is now optional in PUT and POST requests. If the input is not a
  terminal and no data is specified on the command line, resty won't wait
  for data on stdin anymore. If you liked the old behavior you can always do
  something like `cat | POST /Somewhere` for the same effect.

## [1.1] - 2011-01-07
### Fixed
-  bug where `-V` option required input on stdin, and would block waiting  for it.

<!-- Holder history to be retrieved

[unreleased]: https://github.com/micha/resty/compare/v0.10.2...HEAD
[1.5]: https://github.com/micha/resty/compare/1.4...1.5
[1.4]: https://github.com/micha/resty/compare/1.3...1.4
[1.3]: https://github.com/micha/resty/compare/1.2...1.3
[1.2]: https://github.com/micha/resty/compare/1.1...1.2
[1.1]: https://github.com/micha/resty/compare/1.0...1.1
