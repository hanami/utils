
# Lotus::Utils

Ruby core extentions and class utilities for [Lotus](http://lotusrb.org)

## Status

[![Gem Version](http://img.shields.io/gem/v/lotus-utils.svg)](https://badge.fury.io/rb/lotus-utils)
[![Build Status](http://img.shields.io/travis/lotus/utils/master.svg)](https://travis-ci.org/lotus/utils?branch=master)
[![Coverage](http://img.shields.io/coveralls/lotus/utils/master.svg)](https://coveralls.io/r/lotus/utils)
[![Code Climate](http://img.shields.io/codeclimate/github/lotus/utils.svg)](https://codeclimate.com/github/lotus/utils)
[![Dependencies](http://img.shields.io/gemnasium/lotus/utils.svg)](https://gemnasium.com/lotus/utils)
[![Inline Docs](http://inch-ci.org/github/lotus/utils.svg)](http://inch-ci.org/github/lotus/utils)

## Contact

* Home page: http://lotusrb.org
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-utils
* Bugs/Issues: https://github.com/lotus/utils/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Chat: https://gitter.im/lotus/chat

## Rubies

__Lotus::Utils__ supports Ruby (MRI) 2+, JRuby 9k+ & Rubinius 2.3+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotus-utils

## Usage

__Lotus::Utils__ is designed to enhance Ruby's code and stdlib.
**By default this gem doesn't load any code, you must require what you need.**

## Features

### Lotus::Interactor

Standardized Service Object with small interface and rich returning result. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Interactor)]

### Lotus::Logger

Enhanced version of Ruby's `Logger`. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Logger)]

### Lotus::Utils::Attributes

Set of attributes with indifferent access. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Attributes)]

### Lotus::Utils::BasicObject

Enhanced version of Ruby's `BasicObject`. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/BasicObject)]

### Lotus::Utils::Callbacks

Callbacks to decorate methods with `before` and `after` logic. It supports polymorphic callbacks (methods and procs). [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Callbacks)]

### Lotus::Utils::Class

Load classes from strings. It also supports namespaces. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Class)]

### Lotus::Utils::ClassAttribute

Inheritable class attributes. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/ClassAttribute)]

### Lotus::Utils::Deprecation

Deprecate Lotus features. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Deprecation)]

### Lotus::Utils::Duplicable

Safe `#dup` logic for Ruby objects. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Deprecation)]


### Lotus::Utils::Escape

Safe and fast escape for URLs, HTML content and attributes. Based on OWASP/ESAPI code. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Escape)]

### Lotus::Utils::Hash

Enhanced version of Ruby's `Hash`. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Hash)]

### Lotus::Utils::IO

Silence Ruby warnings. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/IO)]

### Lotus::Utils::Inflector

Complete and customizable english inflections (pluralization and singularization). [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Inflector)]

### Lotus::Utils::Kernel

Type coercions for most common Ruby types. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/Kernel)]

### Lotus::Utils::LoadPaths

Manage directories where to find Ruby source code or web static assets. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/LoadPaths)]

### Lotus::Utils::PathPrefix

Safe logic to manage relative URLs. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/PathPrefix)]

### Lotus::Utils::String

Enhanced version of Ruby's `String`. [[API doc](http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/String)]

## Versioning

__Lotus::Utils__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it ( https://github.com/lotus/utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014-2016 Luca Guidi – Released under MIT License
