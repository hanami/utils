# Hanami::Utils

Ruby core extensions and class utilities for [Hanami](http://hanamirb.org)

## Status

[![Gem Version](http://img.shields.io/gem/v/hanami-utils.svg)](https://badge.fury.io/rb/hanami-utils)
[![Build Status](http://img.shields.io/travis/hanami/utils/master.svg)](https://travis-ci.org/hanami/utils?branch=master)
[![Coverage](http://img.shields.io/coveralls/hanami/utils/master.svg)](https://coveralls.io/r/hanami/utils)
[![Code Climate](http://img.shields.io/codeclimate/github/hanami/utils.svg)](https://codeclimate.com/github/hanami/utils)
[![Dependencies](http://img.shields.io/gemnasium/hanami/utils.svg)](https://gemnasium.com/hanami/utils)
[![Inline Docs](http://inch-ci.org/github/hanami/utils.svg)](http://inch-ci.org/github/hanami/utils)

## Contact

* Home page: http://hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-utils
* Bugs/Issues: https://github.com/hanami/utils/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Chat: http://chat.hanamirb.org

## Rubies

__Hanami::Utils__ supports Ruby (MRI) 2.3+, JRuby 9.1.5.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hanami-utils

## Usage

__Hanami::Utils__ is designed to enhance Ruby's code and stdlib.
**By default this gem doesn't load any code, you must require what you need.**

## Features

### Hanami::Interactor

Standardized Service Object with small interface and rich returning result. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Interactor)]

### Hanami::Logger

Enhanced version of Ruby's `Logger`. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Logger)]

### Hanami::Utils::Attributes

Set of attributes with indifferent access. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Attributes)]

### Hanami::Utils::BasicObject

Enhanced version of Ruby's `BasicObject`. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/BasicObject)]

### Hanami::Utils::Blank

Checks for blank. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Blank)]

### Hanami::Utils::Callbacks

Callbacks to decorate methods with `before` and `after` logic. It supports polymorphic callbacks (methods and procs). [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Callbacks)]

### Hanami::Utils::Class

Load classes from strings. It also supports namespaces. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Class)]

### Hanami::Utils::ClassAttribute

Inheritable class attributes. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/ClassAttribute)]

### Hanami::Utils::Deprecation

Deprecate Hanami features. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Deprecation)]

### Hanami::Utils::Duplicable

Safe `#dup` logic for Ruby objects. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Deprecation)]


### Hanami::Utils::Escape

Safe and fast escape for URLs, HTML content and attributes. Based on OWASP/ESAPI code. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Escape)]

### Hanami::Utils::Hash

Enhanced version of Ruby's `Hash`. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Hash)]

### Hanami::Utils::IO

Silence Ruby warnings. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/IO)]

### Hanami::Utils::Inflector

Complete and customizable english inflections (pluralization and singularization). [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Inflector)]

### Hanami::Utils::Kernel

Type coercions for most common Ruby types. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/Kernel)]

### Hanami::Utils::LoadPaths

Manage directories where to find Ruby source code or web static assets. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/LoadPaths)]

### Hanami::Utils::PathPrefix

Safe logic to manage relative URLs. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/PathPrefix)]

### Hanami::Utils::String

Enhanced version of Ruby's `String`. [[API doc](http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/String)]

## Versioning

__Hanami::Utils__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/hanami/utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2017 Luca Guidi – Released under MIT License

This project was formerly known as Lotus (`lotus-utils`).
