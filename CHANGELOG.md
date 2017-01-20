# Changelog

# 1.0.0

* Renamed to LinkPreview

# 0.0.5

* Fixed error when final location is not absolute url
* Removed leading and trailing whitespaces from image urls

# 0.0.4

* Added Changelog, lol ;p
* Removed custom redirect handling in favor of HTTPoison/hackney follow_redirect
* Additional validations to eliminate hackney badarg errors that makes application freeze
* Removed supervisor that did not supervise anything

# 0.0.3

* LinkPreview.parse/1 is no longer separate function, instead it is delegation to LinkPreview.Processor.call/1
* Performance improvement (parallel processing, limiting big lists etc.)
* Removed no longer needed helper functions for Page struct
* Docs improvement

# 0.0.2

* Parsing functions are no longer invoked if previous iteration collected associated data type

# 0.0.1

* First release
