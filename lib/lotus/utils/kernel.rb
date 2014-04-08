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
      # @since 0.1.1
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-Array
      #
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-flatten
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-compact
      # @see http://www.ruby-doc.org/core-2.1.1/Array.html#method-i-uniq
      #
      # @example
      #   require 'lotus/utils/kernel'
      #
      #   Lotus::Utils::Kernel.Array(nil)              # => []
      #   Lotus::Utils::Kernel.Array(1)                # => [1]
      #   Lotus::Utils::Kernel.Array([1])              # => [1]
      #   Lotus::Utils::Kernel.Array([1, [2]])         # => [1,2]
      #   Lotus::Utils::Kernel.Array([1, [2, nil]])    # => [1,2]
      #   Lotus::Utils::Kernel.Array([1, [2, nil, 1]]) # => [1,2]
      def self.Array(arg)
        super(arg).flatten.compact.uniq
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
      # @raise [TypeError,FloatDomainError,RangeError] if the argument can't be
      #   coerced or if it's too big.
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
      #   Lotus::Utils::Kernel.Integer("1")                      # => 1
      #   Lotus::Utils::Kernel.Integer(Rational(0.3))            # => 0
      #   Lotus::Utils::Kernel.Integer(Complex(0.3))             # => 0
      #   Lotus::Utils::Kernel.Integer(BigDecimal.new(12.00001)) # => 12
      #   Lotus::Utils::Kernel.Integer(Time.now)                 # => 1396947161
      #   Lotus::Utils::Kernel.Integer(176605528590345446089)
      #     # => 176605528590345446089
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
      #   require 'bigdecimal'
      #   require 'lotus/utils/kernel'
      #
      #   # Missing #to_int and #to_i
      #   input = OpenStruct.new(color: 'purple')
      #   Lotus::Utils::Kernel.Integer(input) # => TypeError
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
        super(arg) if arg
      rescue ArgumentError
        arg.to_i
      end
    end
  end
end

