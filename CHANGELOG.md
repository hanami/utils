# Hanami::Utils
Ruby core extentions and class utilities for Hanami

## v0.7.0 - (unreleased)
### Changed
- [Luca Guidi] Drop support for Rubinius
- [Luca Guidi] Drop support MRI 2.0, 2.1

## v0.6.1 - 2016-01-19
### Fixed
- [Anton Davydov] Ensure `Hanami::Utils::String#classify` to work properly with dashes (eg. `"app-store" => "App::Store"`)

## v0.6.0 - 2016-01-12
### Added
- [Luca Guidi] Official support for Ruby 2.3
- [Luca Guidi] Custom inflections
- [Luca Guidi] Introduced `Hanami::Utils::Duplicable` as a safe dup logic for Ruby types
- [Luca Guidi] Added `Hanami::Utils::String#rsub` replace rightmost occurrence

### Fixed
- [Luca Guidi] Fix `Hanami::Utils::PathPrefix#join` and `#relative_join` by rejecting arguments that are equal to the separator
- [Karim Kiatlottiavi] Fix `Encoding::UndefinedConversionError` in `Hanami::Utils::Escape.encode`

### Changed
- [Luca Guidi] Deprecate Ruby 2.0 and 2.1
- [Luca Guidi] Removed `Hanami::Utils::Callbacks#add` in favor of `#append`
- [Luca Guidi] Removed pattern support for `Utils::Class.load!` (eg. `Articles(Controller|::Controller)`)

## v0.5.2 - 2015-09-30
### Added
- [Luca Guidi] Added `Hanami::Utils::String#capitalize`
- [Trung Lê] Official support for JRuby 9k+

## v0.5.1 - 2015-07-10
### Fixed
- [Thiago Felippe] Ensure `Hanami::Utils::PathPrefix#join` won't remote duplicate entries (eg `/admin/dashboard/admin`)

## v0.5.0 - 2015-06-23
### Added
- [Luca Guidi] Extracted `Hanami::Logger` from `hanamirb`

### Changed
- [Luca Guidi] `Hanami::Interactor::Result` contains only objects explicitly exposed via `Hanami::Interactor.expose`.

## v0.4.3 - 2015-05-22
### Added
- [François Beausoleil] Improved `Hanami::Utils::Kernel` messages for `TypeError`.

## v0.4.2 - 2015-05-15
### Fixed
- [Luca Guidi] Ensure `Hanami::Utils::Attributes#to_h` to return `::Hash`

## v0.4.1 - 2015-05-15
### Added
- [Luca Guidi & Alfonso Uceda Pompa] Introduced `Hanami::Utils::Inflector`, `Hanami::Utils::String#pluralize` and `#singularize`

### Fixed
- [Luca Guidi] Ensure `Hanami::Utils::Attributes#to_h` to safely return nested `::Hash` instances for complex data structures.
- [Luca Guidi] Let `Hanami::Interactor#error` to return a falsey value for control flow. (eg. `check_permissions or error "You can't access"`)

## v0.4.0 - 2015-03-23
### Added
- [Luca Guidi] Introduced `Hanami::Utils::Escape`. It implements OWASP/ESAPI suggestions for HTML, HTML attribute and URL escape utilities.
- [Luca Guidi] Introduced `Hanami::Utils::String#dasherize`
- [Luca Guidi] Introduced `Hanami::Utils::String#titleize`

## v0.3.5 - 2015-03-12
### Added
- [Luca Guidi] Introduced `Hanami::Interactor`
- [Luca Guidi] Introduced `Hanami::Utils::BasicObject`

## v0.3.4 - 2015-01-30
### Added
- [Alfonso Uceda Pompa] Aliased `Hanami::Utils::Attributes#get` with `#[]`
- [Simone Carletti] Introduced `Hanami::Utils::Callbacks::Chain#prepend` and `#append`

### Deprecated
- [Luca Guidi] Deprecated `Hanami::Utils::Callbacks::Chain#add` in favor of `#append`

## v0.3.3 - 2015-01-08
### Fixed
- [Luca Guidi] Ensure to return the right offending object if a missing method is called with Utils::String and Hash (eg. `Utils::Hash.new(a: 1).all? {|_, v| v.foo }` blame `v` instead of `Hash`)
- [Luca Guidi] Raise an error if try to coerce non numeric strings into Integer, Float & BigDecimal (eg. `Utils::Kernel.Integer("hello") # => raise TypeError`)

## v0.3.2 - 2014-12-23
### Added
- [Luca Guidi] Official support for Ruby 2.2
- [Luca Guidi] Introduced `Utils::Attributes`
- [Luca Guidi] Added `Utils::Hash#stringify!`

## v0.3.1 - 2014-11-23
### Added
- [Luca Guidi] Allow `Utils::Class.load!` to accept any object that implements `#to_s`
- [Trung Lê] Allow `Utils::Class.load!` to accept a class
- [Luca Guidi] Introduced `Utils::Class.load_from_pattern!`
- [Luca Guidi] Introduced `Utils.jruby?` and `Utils.rubinius?`
- [Luca Guidi] Introduced `Utils::Deprecation`
- [Luca Guidi] Official support for Rubinius 2.3+
- [Luca Guidi] Official support for JRuby 1.7+ (with 2.0 mode)
- [Janko Marohnić] Implemented `Utils::PathPrefix` relativness and absolutness
- [Luca Guidi] Made `Utils::PathPrefix` `#join` and `#relative_join` to return a new instance of that class
- [Luca Guidi] Implemented `Utils::Hash#deep_dup`
- [Luca Guidi] Made `Utils::PathPrefix#join` to accept multiple argument

### Fixed
- [Luca Guidi] Made `Utils::PathPrefix#join` remove trailing occurrences for `@separator` from the output
- [Luca Guidi] Made `Utils::PathPrefix#relative_join` to correctly replace all the instances of `@separator` from the output

### Deprecated
- [Luca Guidi] Deprecated `Utils::Class.load!` with a pattern like `Articles(Controller|::Controller)`, use `Utils::Class.load_from_pattern!` instead

## v0.3.0 - 2014-10-23
### Added
- [Celso Fernandes] Add BigDecimal coercion to Hanami::Utils::Kernel
- [Luca Guidi] Define `Boolean` constant, if missing
- [Luca Guidi] Use composition over inheritance for `Hanami::Utils::PathPrefix`
- [Luca Guidi] Use composition over inheritance for `Hanami::Utils::Hash`
- [Luca Guidi] Use composition over inheritance for `Hanami::Utils::String`

### Fixed
- [Luca Guidi] Improved error message for `Utils::Class.load!`
- [Tom Kadwill] Improved error `NameError` message by passing in the whole constant name to `Utils::Class.load!`
- [Luca Guidi] `Utils::Hash#to_h` return instances of `::Hash` in case of nested symbolized data structure
- [Luca Guidi] Raise `TypeError` if `nil` is passed to `PathPrefix#relative_join`
- [Peter Suschlik] Define `Hanami::Utils::Hash#respond_to_missing?`
- [Peter Suschlik] Define `Hanami::Utils::String#responds_to_missing?`
- [Luca Guidi] Ensure `Utils::Hash#inspect` output to be the same of `::Hash#inspect`

## v0.2.0 - 2014-06-23
### Added
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Symbol`
- [Luca Guidi] Made `Kernel.Pathname` to raise an error when `nil` is passed as argument
- [Luca Guidi] Implemented `Hanami::Utils::LoadPaths#freeze` in order to prevent modification after the object has been frozen
- [Luca Guidi] Implemented Hanami::Utils::LoadPaths#push, also aliased as #<<
- [Luca Guidi] Use composition over inheritance for `Hanami::Utils::LoadPaths`
- [Luca Guidi] Introduced `Hanami::Utils::LoadPaths`
- [Luca Guidi] Introduced `Hanami::Utils::String#namespace`, in order to return the top level Ruby namespace for the given string
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Pathname`

### Fixed
- [Luca Guidi] Implemented `Hanami::Utils::LoadPaths#initialize_copy` in order to safely `#dup` and `#clone`

### Changed
- [Luca Guidi] Implemented `Hanami::Utils::Callbacks::Chain#freeze` in order to prevent modification after the object has been frozen
- [Luca Guidi] All the `Utils::Kernel` methods will raise `TypeError` in case of failed coercion.
- [Luca Guidi] Made `Kernel.Time` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.DateTime` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Date` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Boolean` to return false when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.String` to return an empty string when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Float` to return `0.0` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Integer` to return `0` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Hash` to return an empty `Hash` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Set` to return an empty `Set` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Array` to return an empty `Array` when `nil` is passed as argument
- [Luca Guidi] Use composition over inheritance for `Hanami::Utils::Callbacks::Chain`

## v0.1.1 - 2014-04-23
### Added
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Time`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.DateTime`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Date`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Float`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Boolean`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Hash`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Set`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.String`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Integer`
- [Luca Guidi] Implemented `Hanami::Utils::Kernel.Array`

### Fixed
- [Christopher Keele] Add missing stdlib `Set` require to `Utils::ClassAttribute`

## v0.1.0 - 2014-01-23
### Added
- [Luca Guidi] Introduced `Hanami::Utils::String#demodulize`
- [Luca Guidi] Introduced `Hanami::Utils::IO.silence_warnings` 
- [Luca Guidi] Introduced class loading mechanism from a string: `Utils::Class.load!`
- [Luca Guidi] Introduced callbacks support for classes
- [Luca Guidi] Introduced inheritable class level attributes
- [Luca Guidi] Introduced `Utils::Hash`
- [Luca Guidi] Introduced `Utils::String`
- [Luca Guidi] Introduced `Utils::PathPrefix`
- [Luca Guidi] Official support for MRI 2.0+
