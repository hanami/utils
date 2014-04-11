require 'set'

module Lotus
  module Utils
    # Kernel utilities
    # @since 0.1.1
    module Kernel
      # Coerces the argument to be an array.
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
      # @raise [NoMethodError] if arg doesn't implement #nil?
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-Array
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-flatten
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-compact
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-uniq
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Array(nil)              # => nil
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
        super(arg).flatten.compact.uniq unless arg.nil?
      end

      # Coerces the argument to be a set.
      #
      # @param arg [Object] the input
      #
      # @return [Set] the result of the coercion
      #
      # @raise [NoMethodError] if arg doesn't implement #respond_to?
      #
      # @since 0.1.1
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Set(nil)              # => nil
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
      #   Lotus::Utils::Kernel.Set(BasicObject.new) # => NoMethodError
      def self.Set(arg)
        if arg.respond_to?(:to_set)
          arg.to_set
        else
          Set.new(::Kernel.Array(arg))
        end unless arg.nil?
      end

      # Coerces the argument to be an hash.
      #
      # @param arg [Object] the input
      #
      # @return [Hash, nil] the result of the coercion
      #
      # @raise [NoMethodError] if arg doesn't implement #nil?
      # @raise [NoMethodError] if arg doesn't implement #respond_to?
      # @raise [TypeError] if arg can't be coerced
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-Hash
      #
      # @example Basic Usage
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Hash(nil)                 # => nil
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
      #   Lotus::Utils::Kernel.Hash(input) # => NoMethodError
      def self.Hash(arg)
        if arg.respond_to?(:to_h)
          arg.to_h
        else
          super(arg)
        end unless arg.nil?
      end

      # Coerces the argument to be an integer.
      #
      # It's similar to Ruby's Kernel.Integer, but it doesn't stop at the first
      # error and tries to be less "whiny".
      #
      # @param arg [Object] the argument
      #
      # @return [Fixnum,nil] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      # @raise [NoMethodError] if the argument doesn't implenent #nil?
      # @raise [TypeError,FloatDomainError,RangeError] if the argument it's too
      #   big.
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-Integer
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
      #   Lotus::Utils::Kernel.Integer(nil) # => nil
      #
      #   # float represented as a string
      #   Kernel.Integer("23.4")               # => ArgumentError
      #   Lotus::Utils::Kernel.Integer("23.4") # => 23
      #
      #   # rational represented as a string
      #   Kernel.Integer("2/3")               # => ArgumentError
      #   Lotus::Utils::Kernel.Integer("2/3") # => 2
      #
      #   # complex represented as a string
      #   Kernel.Integer("2.5/1")               # => ArgumentError
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
      #   # Missing #nil?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.Integer(input) # => NoMethodError
      #
      #   # bigdecimal infinity
      #   input = BigDecimal.new("Infinity")
      #   Lotus::Utils::Kernel.Integer(input) # => FloatDomainError
      #
      #   # bigdecimal NaN
      #   input = BigDecimal.new("NaN")
      #   Lotus::Utils::Kernel.Integer(input) # => FloatDomainError
      #
      #   # big rational
      #   input = Rational(-8) ** Rational(1, 3)
      #   Lotus::Utils::Kernel.Integer(input) # => RangeError
      #
      #   # big complex represented as a string
      #   input = Complex(2, 3)
      #   Lotus::Utils::Kernel.Integer(input) # => RangeError
      def self.Integer(arg)
        super(arg) unless arg.nil?
      rescue ArgumentError
        arg.to_i
      end

      # Coerces the argument to be a string.
      #
      # It's similar to Ruby's Kernel.String, but it's less "whiny".
      #
      # @param arg [Object] the argument
      #
      # @return [String,nil] the result of the coercion
      #
      # @raise [TypeError] if the argument can't be coerced
      # @raise [NoMethodError] if the argument doesn't implement #nil?
      #
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-String
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
      #     def nil?
      #       false
      #     end
      #
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
      # @example Error Handling
      #   require 'lotus/utils/kernel'
      #
      #   # nil
      #   Kernel.String(nil)               # => ""
      #   Lotus::Utils::Kernel.String(nil) # => nil
      #
      # @example Unchecked Exceptions
      #   require 'lotus/utils/kernel'
      #
      #   BaseObject = Class.new(BasicObject) do
      #     def nil?
      #       false
      #     end
      #   end
      #
      #   # Missing #nil?
      #   input = BasicObject.new
      #   Lotus::Utils::Kernel.String(input)  # => NoMethodError
      #
      #   # Missing #to_s or #to_str
      #   input = BaseObject.new
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
      def self.String(arg)
        super(arg) unless arg.nil?
      end
    end
  end
end

