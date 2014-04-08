module Lotus
  module Utils
    # Kernel utilities
    # @since 0.1.1
    module Kernel
      # Coerces an the argument to be an array.
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
    end
  end
end

