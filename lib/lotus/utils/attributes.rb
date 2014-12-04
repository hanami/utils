require 'lotus/utils/hash'

module Lotus
  module Utils
    # A set of attributes.
    #
    # It internally stores the data as a Hash.
    #
    # All the operations convert keys to strings.
    # This strategy avoids memory attacks due to Symbol abuses when parsing
    # untrusted input.
    #
    # At the same time, this allows to get/set data with the original key or
    # with the string representation. See the examples below.
    #
    # @since x.x.x
    class Attributes
      # Initialize a set of attributes
      # All the keys of the given Hash are recursively converted to strings.
      #
      # @param hash [#to_h] a Hash or any object that implements #to_h
      #
      # @return [Lotus::Utils::Attributes] self
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/utils/attributes'
      #
      #   attributes = Lotus::Utils::Attributes.new(a: 1, b: { 2 => [3, 4] } })
      #   attributes.to_h # => { "a" => 1, "b" => { "2" => [3, 4] } }
      def initialize(hash = {})
        @attributes = Utils::Hash.new(hash, &nil).stringify!
      end

      # Get the value associated with the given attribute
      #
      # @param attribute [#to_s] a String or any object that implements #to_s
      #
      # @return [Object,NilClass] the associated value, if present
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/utils/attributes'
      #
      #   attributes = Lotus::Utils::Attributes.new(a: 1, 'b' => 2, 23 => 'foo')
      #
      #   attributes.get(:a)  # => 1
      #   attributes.get('a') # => 1
      #
      #   attributes.get(:b)  # => 2
      #   attributes.get('b') # => 2
      #
      #   attributes.get(23)   # => "foo"
      #   attributes.get('23') # => "foo"
      #
      #   attributes.get(:unknown)  # => nil
      #   attributes.get('unknown') # => nil
      def get(attribute)
        @attributes[attribute.to_s]
      end

      # Set the given value for the given attribute
      #
      # @param attribute [#to_s] a String or any object that implements #to_s
      # @param value [Object] any value
      #
      # @return [NilClass]
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/utils/attributes'
      #
      #   attributes = Lotus::Utils::Attributes.new
      #
      #   attributes.set(:a, 1)
      #   attributes.get(:a)  # => 1
      #   attributes.get('a') # => 1
      #
      #   attributes.set('b', 2)
      #   attributes.get(:b)  # => 2
      #   attributes.get('b') # => 2
      #
      #   attributes.set(23, 'foo')
      #   attributes.get(23)   # => "foo"
      #   attributes.get('23') # => "foo"
      def set(attribute, value)
        @attributes[attribute.to_s] = value
        nil
      end

      # Returns a deep duplicated copy of the attributes as a Hash
      #
      # @return [Lotus::Utils::Hash]
      #
      # @since x.x.x
      #
      # @see Lotus::Utils::Hash
      def to_h
        @attributes.deep_dup
      end
    end
  end
end
