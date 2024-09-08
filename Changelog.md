# Yard-Junk changelog

## 0.0.10 -- 2024-09-08

* Update to support newer Rubies (by [@pboling](https://github.com/pboling) at [#42](https://github.com/zverok/yard-junk/pull/42))
* Drop support for Ruby < 2.7

## 0.0.9 -- 2020-12-05

* Avoid deprecation warnings ([640bc355d](https://github.com/zverok/yard-junk/commit/640bc355d156e892348b80210fc034af25e196cf))

## 0.0.8 -- 2020-11-12

* Support Ruby 2.7 (and hopefully 3.0)
* Drop support for Rubies below 2.5 :shrug:

## 0.0.7 -- 2017-09-21

* Fix problems with links resolution for RDoc.

## 0.0.6 -- 2017-09-20

* More robust (and more logical) colorization on text output (#25);
* Fast "sanity check" for using in pre-commit hook on large codebases (#24).

## 0.0.5 -- 2017-09-11

* Fix gem conflict with `did_you_mean`.

## 0.0.4 -- 2017-09-09

* Support for partial reports `yard-junk --path path/to/folder` (#13)

## 0.0.3 -- 2017-09-07

* Wiser dependency on `did_you_mean`, should not break CIs now.
* Support for Ruby 2.1 and 2.2.

## 0.0.2 -- 2017-09-03

* Lots of small cleanups and enchancement of README, Gemfile and directory structure ([@olleolleolle]);
* Colorized text output ([@olleolleolle]);
* HTML reporter;
* Options for command line and Rake task.

## 0.0.1 -- 2017-08-27

Yard-Junk was born (Even RubyWeekly [#364](http://rubyweekly.com/issues/364) noticed!)
