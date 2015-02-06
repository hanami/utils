require 'set'
require 'date'
require 'time'
require 'pathname'
require 'bigdecimal'
require 'lotus/utils'

# Define top level constant Boolean, so it can be easily used by other libraries
# in coercions DSLs
#
# @since 0.3.0
class Boolean
end unless defined?(Boolean)

module Lotus
  module Utils
    # Kernel utilities
    # @since 0.1.1
    module Kernel
      # Matcher for numeric values
      #
      # @since 0.3.3
      # @api private
      #
      # @see Lotus::Utils::Kernel.Integer
      NUMERIC_MATCHER = /\A([\d\/\.\+iE]+|NaN|Infinity)\z/.freeze

      # Coerces the argument to be an Array.
      #
      # It's similar to Ruby's Kernel.Array, but it applies further
      # transformations:
      #
      #   * flatten
      #   * compact
      #   * uniq
      #
      # @param arg [Object] the input
      #
      # @return [Array] the result of the coercion
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core/Kernel.html#method-i-Array
      #
      # @see http://www.ruby-doc.org/core/Array.html#method-i-flatten
      # @see http://www.ruby-doc.org/core/Array.html#method-i-compact
      # @see http://www.ruby-doc.org/core/Array.html#method-i-uniq
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Array(nil)              # => []
      #   Lotus::Utils::Kernel.Array(true)             # => [true]
      #   Lotus::Utils::Kernel.Array(false)            # => [false]
      #   Lotus::Utils::Kernel.Array(1)                # => [1]
      #   Lotus::Utils::Kernel.Array([1])              # => [1]
      #   Lotus::Utils::Kernel.Array([1, [2]])         # => [1,2]
      #   Lotus::Utils::Kernel.Array([1, [2, nil]])    # => [1,2]
      #   Lotus::Utils::Kernel.Array([1, [2, nil, 1]]) # => [1,2]
      #
      # @example Array Interface
      #   require 'lotus/utils/kernel'
      #
      #   ResultSet = Struct.new(:records) do
      #     def to_a
      #       records.to_a.sort
      #     end
      #   end
      #
      #   Response = Struct.new(:status, :headers, :body) do
      #     def to_ary
      #       [status, headers, body]
      #     end
      #   end
      #
      #   set = ResultSet.new([2,1,3])
      #   Lotus::Utils::Kernel.Array(set)              # => [1,2,3]
      #
      #   response = Response.new(200, {}, 'hello')
      #   Lotus::Utils::Kernel.Array(response)         # => [200, {}, "hello"]
      def self.Array(arg)
        super(arg).dup.tap do |a|
          a.flatten!
          a.compact!
          a.uniq!
        end
      end

      # Coerces the argument to be a Set.
      #
      # @param arg [Object] the input
      #
      # @return [Set] the result of the coercion
      #
      # @raise [TypeError] if arg doesn't implement #respond_to?
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Set(nil)              # => #<Set: {}>
      #   Lotus::Utils::Kernel.Set(true)             # => #<Set: {true}>
      #   Lotus::Utils::Kernel.Set(false)            # => #<Set: {false}>
      #   Lotus::Utils::Kernel.Set(1)                # => #<Set: {1}>
      #   Lotus::Utils::Kernel.Set([1])              # => #<Set: {1}>
      #   Lotus::Utils::Kernel.Set([1, 1])           # => #<Set: {1}>
      #   Lotus::Utils::Kernel.Set([1, [2]])         # => #<Set: {1, [2]}>
      #   Lotus::Utils::Kernel.Set([1, [2, nil]])    # => #<Set: {1, [2, nil]}>
      #   Lotus::Utils::Kernel.Set({a: 1})           # => #<Set: {[:a, 1]}>
      #
      # @example Set Interface
      #   require 'securerandom'
      #   require 'lotus/utils/kernel'
      #
      #   UuidSet = Class.new do
      #     def initialize(*uuids)
      #       @uuids = uuids
      #     end
      #
      #     def to_set
      #       Set.new.tap do |set|
      #         @uuids.each {|uuid| set.add(uuid) }
      #       end
      #     end
      #   end
      #
      #   uuids = UuidSet.new(SecureRandom.uuid)
      #   Lotus::Utils::Kernel.Set(uuids)
      #     # => #<Set: {"daa798b4-630c-4e11-b29d-92f0b1c7d075"}>
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Set(BasicObject.new) # => TypeError
      def self.Set(arg)
        if arg.respond_to?(:to_set)
          arg.to_set
        else
          Set.new(::Kernel.Array(arg))
        end
      rescue NoMethodError
        raise TypeError.new("can't convert into Set")
      end

      # Coerces the argument to be a Hash.
      #
      # @param arg [Object] the input
      #
      # @return [Hash] the result of the coercion
      #
      # @raise [TypeError] if arg can't be coerced
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core/Kernel.html#method-i-Hash
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Hash(nil)                 # => {}
      #   Lotus::Utils::Kernel.Hash({a: 1})              # => { :a => 1 }
      #   Lotus::Utils::Kernel.Hash([[:a, 1]])           # => { :a => 1 }
      #   Lotus::Utils::Kernel.Hash(Set.new([[:a, 1]]))  # => { :a => 1 }
      #
      # @example Hash Interface
      #   require 'lotus/utils/kernel'
      #
      #   Room = Class.new do
      #     def initialize(*args)
      #       @args = args
      #     end
      #
      #     def to_h
      #       Hash[*@args]
      #     end
      #   end
      #
      #   Record = Class.new do
      #     def initialize(attributes = {})
      #       @attributes = attributes
      #     end
      #
      #     def to_hash
      #       @attributes
      #     end
      #   end
      #
      #   room = Room.new(:key, 123456)
      #   Lotus::Utils::Kernel.Hash(room)        # => { :key => 123456 }
      #
      #   record = Record.new(name: 'L')
      #   Lotus::Utils::Kernel.Hash(record)      # => { :name => "L" }
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Hash(input) # => TypeError
      def self.Hash(arg)
        if arg.respond_to?(:to_h)
          arg.to_h
        else
          super(arg)
        end
      rescue NoMethodError
        raise TypeError.new "can't convert into Hash"
      end

      # Coerces the argument to be an Integer.
      #
      # It's similar to Ruby's Kernel.Integer, but it doesn't stop at the first
      # error and raise an exception only when the argument can't be coerced.
      #
      # @param arg [Object] the argument
      #
      # @return [Fixnum] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core/Kernel.html#method-i-Integer
      #
      # @example Basic Usage
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Integer(1)                        # => 1
      #   Lotus::Utils::Kernel.Integer(1.2)                      # => 1
      #   Lotus::Utils::Kernel.Integer(011)                      # => 9
      #   Lotus::Utils::Kernel.Integer(0xf5)                     # => 245
      #   Lotus::Utils::Kernel.Integer("1")                      # => 1
      #   Lotus::Utils::Kernel.Integer(Rational(0.3))            # => 0
      #   Lotus::Utils::Kernel.Integer(Complex(0.3))             # => 0
      #   Lotus::Utils::Kernel.Integer(BigDecimal.new(12.00001)) # => 12
      #   Lotus::Utils::Kernel.Integer(176605528590345446089)
      #     # => 176605528590345446089
      #
      #   Lotus::Utils::Kernel.Integer(Time.now)                 # => 1396947161
      #
      # @example Integer Interface
      #   require 'lotus/utils/kernel'
      #
      #   UltimateAnswer = Struct.new(:question) do
      #     def to_int
      #       42
      #     end
      #   end
      #
      #   answer = UltimateAnswer.new('The Ultimate Question of Life')
      #   Lotus::Utils::Kernel.Integer(answer) # => 42
      #
      # @example Error Handling
      #   require 'lotus/utils/kernel'
      #
      #   # nil
      #   Kernel.Integer(nil)               # => TypeError
      #   Lotus::Utils::Kernel.Integer(nil) # => 0
      #
      #   # float represented as a string
      #   Kernel.Integer("23.4")               # => TypeError
      #   Lotus::Utils::Kernel.Integer("23.4") # => 23
      #
      #   # rational represented as a string
      #   Kernel.Integer("2/3")               # => TypeError
      #   Lotus::Utils::Kernel.Integer("2/3") # => 2
      #
      #   # complex represented as a string
      #   Kernel.Integer("2.5/1")               # => TypeError
      #   Lotus::Utils::Kernel.Integer("2.5/1") # => 2
      #
      # @example Unchecked Exceptions
      #   require 'date'
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   # Missing #to_int and #to_i
      #   input = OpenStruct.new(color: 'purple')
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # String that doesn't represent an integer
      #   input = 'hello'
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # When true
      #   input = true
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # When false
      #   input = false
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # When Date
      #   input = Date.today
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # When DateTime
      #   input = DateTime.now
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # bigdecimal infinity
      #   input = BigDecimal.new("Infinity")
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # bigdecimal NaN
      #   input = BigDecimal.new("NaN")
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # big rational
      #   input = Rational(-8) ** Rational(1, 3)
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      #
      #   # big complex represented as a string
      #   input = Complex(2, 3)
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      def self.Integer(arg)
        super(arg)
      rescue ArgumentError, TypeError, NoMethodError
        begin
          case arg
          when NilClass, ->(a) { a.respond_to?(:to_i) && a.to_s.match(NUMERIC_MATCHER) }
            arg.to_i
          else
            raise TypeError.new "can't convert into Integer"
          end
        rescue NoMethodError
          raise TypeError.new "can't convert into Integer"
        end
      rescue RangeError
        raise TypeError.new "can't convert into Integer"
      end

      # Coerces the argument to be a BigDecimal.
      #
      # @param arg [Object] the argument
      #
      # @return [BigDecimal] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.3.0
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/bigdecimal/rdoc/BigDecimal.html
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.BigDecimal(1)                        # => 1
      #   Lotus::Utils::Kernel.BigDecimal(1.2)                      # => 1
      #   Lotus::Utils::Kernel.BigDecimal(011)                      # => 9
      #   Lotus::Utils::Kernel.BigDecimal(0xf5)                     # => 245
      #   Lotus::Utils::Kernel.BigDecimal("1")                      # => 1
      #   Lotus::Utils::Kernel.BigDecimal(Rational(0.3))            # => 0.3
      #   Lotus::Utils::Kernel.BigDecimal(Complex(0.3))             # => 0.3
      #   Lotus::Utils::Kernel.BigDecimal(BigDecimal.new(12.00001)) # => 12.00001
      #   Lotus::Utils::Kernel.BigDecimal(176605528590345446089)
      #     # => 176605528590345446089
      #
      # @example BigDecimal Interface
      #   require 'lotus/utils/kernel'
      #
      #   UltimateAnswer = Struct.new(:question) do
      #     def to_d
      #       BigDecimal.new(42)
      #     end
      #   end
      #
      #   answer = UltimateAnswer.new('The Ultimate Question of Life')
      #   Lotus::Utils::Kernel.BigDecimal(answer)
      #     # => #<BigDecimal:7fabfd148588,'0.42E2',9(27)>
      #
      # @example Unchecked exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # When nil
      #   input = nil
      #   Lotus::Utils::Kernel.BigDecimal(nil) # => TypeError
      #
      #   # When true
      #   input = true
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # When false
      #   input = false
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # When Date
      #   input = Date.today
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # When DateTime
      #   input = DateTime.now
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # When Time
      #   input = Time.now
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # String that doesn't represent a big decimal
      #   input = 'hello'
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.BigDecimal(input) # => TypeError
      def self.BigDecimal(arg)
        case arg
        when ->(a) { a.respond_to?(:to_d) } then arg.to_d
        when Float, Complex, Rational
          BigDecimal(arg.to_s)
        when ->(a) { a.to_s.match(NUMERIC_MATCHER) }
          BigDecimal.new(arg)
        else
          raise TypeError.new "can't convert into BigDecimal"
        end
      rescue NoMethodError
        raise TypeError.new "can't convert into BigDecimal"
      end

      # Coerces the argument to be a Float.
      #
      # It's similar to Ruby's Kernel.Float, but it doesn't stop at the first
      # error and raise an exception only when the argument can't be coerced.
      #
      # @param arg [Object] the argument
      #
      # @return [Float] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core/Kernel.html#method-i-Float
      #
      # @example Basic Usage
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Float(1)                        # => 1.0
      #   Lotus::Utils::Kernel.Float(1.2)                      # => 1.2
      #   Lotus::Utils::Kernel.Float(011)                      # => 9.0
      #   Lotus::Utils::Kernel.Float(0xf5)                     # => 245.0
      #   Lotus::Utils::Kernel.Float("1")                      # => 1.0
      #   Lotus::Utils::Kernel.Float(Rational(0.3))            # => 0.3
      #   Lotus::Utils::Kernel.Float(Complex(0.3))             # => 0.3
      #   Lotus::Utils::Kernel.Float(BigDecimal.new(12.00001)) # => 12.00001
      #   Lotus::Utils::Kernel.Float(176605528590345446089)
      #     # => 176605528590345446089.0
      #
      #   Lotus::Utils::Kernel.Float(Time.now) # => 397750945.515169
      #
      # @example Float Interface
      #   require 'lotus/utils/kernel'
      #
      #   class Pi
      #     def to_f
      #       3.14
      #     end
      #   end
      #
      #   pi = Pi.new
      #   Lotus::Utils::Kernel.Float(pi) # => 3.14
      #
      # @example Error Handling
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   # nil
      #   Kernel.Float(nil)               # => TypeError
      #   Lotus::Utils::Kernel.Float(nil) # => 0.0
      #
      #   # float represented as a string
      #   Kernel.Float("23.4")               # => TypeError
      #   Lotus::Utils::Kernel.Float("23.4") # => 23.4
      #
      #   # rational represented as a string
      #   Kernel.Float("2/3")               # => TypeError
      #   Lotus::Utils::Kernel.Float("2/3") # => 2.0
      #
      #   # complex represented as a string
      #   Kernel.Float("2.5/1")               # => TypeError
      #   Lotus::Utils::Kernel.Float("2.5/1") # => 2.5
      #
      #   # bigdecimal infinity
      #   input = BigDecimal.new("Infinity")
      #   Lotus::Utils::Kernel.Float(input) # => Infinity
      #
      #   # bigdecimal NaN
      #   input = BigDecimal.new("NaN")
      #   Lotus::Utils::Kernel.Float(input) # => NaN
      #
      # @example Unchecked Exceptions
      #   require 'date'
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   # Missing #to_f
      #   input = OpenStruct.new(color: 'purple')
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # When true
      #   input = true
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # When false
      #   input = false
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # When Date
      #   input = Date.today
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # When DateTime
      #   input = DateTime.now
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # Missing #nil?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # String that doesn't represent a float
      #   input = 'hello'
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # big rational
      #   input = Rational(-8) ** Rational(1, 3)
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      #
      #   # big complex represented as a string
      #   input = Complex(2, 3)
      #   Lotus::Utils::Kernel.Float(input) # => TypeError
      def self.Float(arg)
        super(arg)
      rescue ArgumentError, TypeError
        begin
          case arg
          when NilClass, ->(a) { a.respond_to?(:to_f) && a.to_s.match(NUMERIC_MATCHER) }
            arg.to_f
          else
            raise TypeError.new "can't convert into Float"
          end
        rescue NoMethodError
          raise TypeError.new "can't convert into Float"
        end
      rescue RangeError
        raise TypeError.new "can't convert into Float"
      end

      # Coerces the argument to be a String.
      #
      # Identical behavior of Ruby's Kernel.Array, still here because we want
      # to keep the interface consistent
      #
      # @param arg [Object] the argument
      #
      # @return [String] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core/Kernel.html#method-i-String
      #
      # @example Basic Usage
      #   require 'date'
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.String('')                            # => ""
      #   Lotus::Utils::Kernel.String('ciao')                        # => "ciao"
      #
      #   Lotus::Utils::Kernel.String(true)                          # => "true"
      #   Lotus::Utils::Kernel.String(false)                         # => "false"
      #
      #   Lotus::Utils::Kernel.String(:lotus)                        # => "lotus"
      #
      #   Lotus::Utils::Kernel.String(Picture)                       # => "Picture" # class
      #   Lotus::Utils::Kernel.String(Lotus)                         # => "Lotus" # module
      #
      #   Lotus::Utils::Kernel.String([])                            # => "[]"
      #   Lotus::Utils::Kernel.String([1,2,3])                       # => "[1, 2, 3]"
      #   Lotus::Utils::Kernel.String(%w[a b c])                     # => "[\"a\", \"b\", \"c\"]"
      #
      #   Lotus::Utils::Kernel.String({})                            # => "{}"
      #   Lotus::Utils::Kernel.String({a: 1, 'b' => 'c'})            # => "{:a=>1, \"b\"=>\"c\"}"
      #
      #   Lotus::Utils::Kernel.String(Date.today)                    # => "2014-04-11"
      #   Lotus::Utils::Kernel.String(DateTime.now)                  # => "2014-04-11T10:15:06+02:00"
      #   Lotus::Utils::Kernel.String(Time.now)                      # => "2014-04-11 10:15:53 +0200"
      #
      #   Lotus::Utils::Kernel.String(1)                             # => "1"
      #   Lotus::Utils::Kernel.String(3.14)                          # => "3.14"
      #   Lotus::Utils::Kernel.String(013)                           # => "11"
      #   Lotus::Utils::Kernel.String(0xc0ff33)                      # => "12648243"
      #
      #   Lotus::Utils::Kernel.String(Rational(-22))                 # => "-22/1"
      #   Lotus::Utils::Kernel.String(Complex(11, 2))                # => "11+2i"
      #   Lotus::Utils::Kernel.String(BigDecimal.new(7944.2343, 10)) # => "0.79442343E4"
      #   Lotus::Utils::Kernel.String(BigDecimal.new('Infinity'))    # => "Infinity"
      #   Lotus::Utils::Kernel.String(BigDecimal.new('NaN'))         # => "Infinity"
      #
      # @example String interface
      #   require 'lotus/utils/kernel'
      #
      #   SimpleObject = Class.new(BasicObject) do
      #     def to_s
      #       'simple object'
      #     end
      #   end
      #
      #   Isbn = Struct.new(:code) do
      #     def to_str
      #       code.to_s
      #     end
      #   end
      #
      #   simple = SimpleObject.new
      #   isbn   = Isbn.new(123)
      #
      #   Lotus::Utils::Kernel.String(simple) # => "simple object"
      #   Lotus::Utils::Kernel.String(isbn)   # => "123"
      #
      # @example Comparison with Ruby
      #   require 'lotus/utils/kernel'
      #
      #   # nil
      #   Kernel.String(nil)               # => ""
      #   Lotus::Utils::Kernel.String(nil) # => ""
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # Missing #to_s or #to_str
      #   input = BaseObject.new
      #   Lotus::Utils::Kernel.String(input) # => TypeError
      if Utils.rubinius?
        def self.String(arg)
          case arg
          when ->(a) { a.respond_to?(:to_str) }
            arg.to_str
          when ->(a) { a.respond_to?(:to_s) }
            arg.to_s
          else
            super(arg)
          end
        rescue NoMethodError
          raise TypeError.new "can't convert into String"
        end
      else
        def self.String(arg)
          arg = arg.to_str if arg.respond_to?(:to_str)
          super(arg)
        rescue NoMethodError
          raise TypeError.new "can't convert into String"
        end
      end

      # Coerces the argument to be a Date.
      #
      # @param arg [Object] the argument
      #
      # @return [Date] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Date(Date.today)
      #     # => #<Date: 2014-04-17 ((2456765j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.Date(DateTime.now)
      #     # => #<Date: 2014-04-17 ((2456765j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.Date(Time.now)
      #     # => #<Date: 2014-04-17 ((2456765j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.Date('2014-04-17')
      #     # => #<Date: 2014-04-17 ((2456765j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.Date('2014-04-17 22:37:15')
      #     # => #<Date: 2014-04-17 ((2456765j,0s,0n),+0s,2299161j)>
      #
      # @example Date Interface
      #   require 'lotus/utils/kernel'
      #
      #   class Christmas
      #     def to_date
      #       Date.parse('Dec, 25')
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Date(Christmas.new)
      #     # => #<Date: 2014-12-25 ((2457017j,0s,0n),+0s,2299161j)>
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # nil
      #   input = nil
      #   Lotus::Utils::Kernel.Date(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Date(input) # => TypeError
      #
      #   # Missing #to_s?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Date(input) # => TypeError
      def self.Date(arg)
        if arg.respond_to?(:to_date)
          arg.to_date
        else
          Date.parse(arg.to_s)
        end
      rescue ArgumentError, NoMethodError
        raise TypeError.new "can't convert into Date"
      end

      # Coerces the argument to be a DateTime.
      #
      # @param arg [Object] the argument
      #
      # @return [DateTime] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.DateTime(3483943)
      #     # => Time.at(3483943).to_datetime #<DateTime: 1970-02-10T08:45:43+01:00 ((2440628j,27943s,0n),+3600s,2299161j)>
      #
      #   Lotus::Utils::Kernel.DateTime(DateTime.now)
      #     # => #<DateTime: 2014-04-18T09:33:49+02:00 ((2456766j,27229s,690849000n),+7200s,2299161j)>
      #
      #   Lotus::Utils::Kernel.DateTime(Date.today)
      #     # => #<DateTime: 2014-04-18T00:00:00+00:00 ((2456766j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.Date(Time.now)
      #     # => #<DateTime: 2014-04-18T09:34:49+02:00 ((2456766j,27289s,832907000n),+7200s,2299161j)>
      #
      #   Lotus::Utils::Kernel.DateTime('2014-04-18')
      #     # => #<DateTime: 2014-04-18T00:00:00+00:00 ((2456766j,0s,0n),+0s,2299161j)>
      #
      #   Lotus::Utils::Kernel.DateTime('2014-04-18 09:35:42')
      #     # => #<DateTime: 2014-04-18T09:35:42+00:00 ((2456766j,34542s,0n),+0s,2299161j)>
      #
      # @example DateTime Interface
      #   require 'lotus/utils/kernel'
      #
      #   class NewYearEve
      #     def to_datetime
      #       DateTime.parse('Jan, 1')
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Date(NewYearEve.new)
      #     # => #<DateTime: 2014-01-01T00:00:00+00:00 ((2456659j,0s,0n),+0s,2299161j)>
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # When nil
      #   input = nil
      #   Lotus::Utils::Kernel.DateTime(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.DateTime(input) # => TypeError
      #
      #   # Missing #to_s?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.DateTime(input) # => TypeError
      def self.DateTime(arg)
        case arg
        when ->(a) { a.respond_to?(:to_datetime) } then arg.to_datetime
        when Numeric then DateTime(Time.at(arg))
        else
          DateTime.parse(arg.to_s)
        end
      rescue ArgumentError, NoMethodError
        raise TypeError.new "can't convert into DateTime"
      end

      # Coerces the argument to be a Time.
      #
      # @param arg [Object] the argument
      #
      # @return [Time] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Time(Time.now)
      #     # => 2014-04-18 15:56:39 +0200
      #
      #   Lotus::Utils::Kernel.Time(DateTime.now)
      #     # => 2014-04-18 15:56:39 +0200
      #
      #   Lotus::Utils::Kernel.Time(Date.today)
      #     # => 2014-04-18 00:00:00 +0200
      #
      #   Lotus::Utils::Kernel.Time('2014-04-18')
      #     # => 2014-04-18 00:00:00 +0200
      #
      #   Lotus::Utils::Kernel.Time('2014-04-18 15:58:02')
      #     # => 2014-04-18 15:58:02 +0200
      #
      # @example Time Interface
      #   require 'lotus/utils/kernel'
      #
      #   class Epoch
      #     def to_time
      #       Time.at(0)
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Time(Epoch.new)
      #     # => 1970-01-01 01:00:00 +0100
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # When nil
      #   input = nil
      #   Lotus::Utils::Kernel.Time(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Time(input) # => TypeError
      #
      #   # Missing #to_s?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Time(input) # => TypeError
      def self.Time(arg)
        case arg
        when ->(a) { a.respond_to?(:to_time) } then arg.to_time
        when Numeric then Time.at(arg)
        else
          Time.parse(arg.to_s)
        end
      rescue ArgumentError, NoMethodError
        raise TypeError.new "can't convert into Time"
      end

      # Coerces the argument to be a Boolean.
      #
      # @param arg [Object] the argument
      #
      # @return [true,false] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Boolean(nil)                      # => false
      #   Lotus::Utils::Kernel.Boolean(0)                        # => false
      #   Lotus::Utils::Kernel.Boolean(1)                        # => true
      #   Lotus::Utils::Kernel.Boolean('0')                      # => false
      #   Lotus::Utils::Kernel.Boolean('1')                      # => true
      #   Lotus::Utils::Kernel.Boolean(Object.new)               # => true
      #
      # @example Boolean Interface
      #   require 'lotus/utils/kernel'
      #
      #   Answer = Struct.new(:answer) do
      #     def to_bool
      #       case answer
      #       when 'yes' then true
      #       else false
      #       end
      #     end
      #   end
      #
      #   answer = Answer.new('yes')
      #   Lotus::Utils::Kernel.Boolean(answer) # => true
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Boolean(input) # => TypeError
      def self.Boolean(arg)
        case arg
        when Numeric     then arg > 0 && arg <= 1
        when String, '0' then Boolean(arg.to_i)
        when ->(a) { a.respond_to?(:to_bool) } then arg.to_bool
        else
          !!arg
        end
      rescue NoMethodError
        raise TypeError.new "can't convert into Boolean"
      end

      # Coerces the argument to be a Pathname.
      #
      # @param arg [#to_pathname,#to_str] the argument
      #
      # @return [Pathname] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.1.2
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Pathname(Pathname.new('/path/to')) # => #<Pathname:/path/to>
      #   Lotus::Utils::Kernel.Pathname('/path/to')               # => #<Pathname:/path/to>
      #
      # @example Pathname Interface
      #   require 'lotus/utils/kernel'
      #
      #   class HomePath
      #     def to_pathname
      #       Pathname.new Dir.home
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Pathname(HomePath.new) # => #<Pathname:/Users/luca>
      #
      # @example String Interface
      #   require 'lotus/utils/kernel'
      #
      #   class RootPath
      #     def to_str
      #       '/'
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Pathname(RootPath.new) # => #<Pathname:/>
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # When nil
      #   input = nil
      #   Lotus::Utils::Kernel.Pathname(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Pathname(input) # => TypeError
      def self.Pathname(arg)
        case arg
        when ->(a) { a.respond_to?(:to_pathname) } then arg.to_pathname
        else
          super
        end
      rescue NoMethodError
        raise TypeError.new "can't convert into Pathname"
      end

      # Coerces the argument to be a String.
      #
      # @param arg [#to_sym] the argument
      #
      # @return [Symbol] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      #
      # @since 0.2.0
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Symbol(:hello)  # => :hello
      #   Lotus::Utils::Kernel.Symbol('hello') # => :hello
      #
      # @example Symbol Interface
      #   require 'lotus/utils/kernel'
      #
      #   class StatusSymbol
      #     def to_sym
      #       :success
      #     end
      #   end
      #
      #   Lotus::Utils::Kernel.Symbol(StatusSymbol.new) # => :success
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   # When nil
      #   input = nil
      #   Lotus::Utils::Kernel.Symbol(input) # => TypeError
      #
      #   # When empty string
      #   input = ''
      #   Lotus::Utils::Kernel.Symbol(input) # => TypeError
      #
      #   # Missing #respond_to?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Symbol(input) # => TypeError
      def self.Symbol(arg)
        case arg
        when '' then raise TypeError.new "can't convert into Symbol"
        when ->(a) { a.respond_to?(:to_sym) } then arg.to_sym
        else
          raise TypeError.new "can't convert into Symbol"
        end
      rescue NoMethodError
        raise TypeError.new "can't convert into Symbol"
      end
    end
  end
end

