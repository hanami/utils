require 'hanami/utils/hash'

module Hanami
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
    # @since 0.3.2
    class Attributes
      # Initialize a set of attributes
      # All the keys of the given Hash are recursively converted to strings.
      #
      # @param hash [#to_h] a Hash or any object that implements #to_h
      #
      # @return [Hanami::Utils::Attributes] self
      #
      # @since 0.3.2
      #
      # @example
      #   require 'hanami/utils/attributes'
      #
      #   attributes = Hanami::Utils::Attributes.new(a: 1, b: { 2 => [3, 4] })
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
      # @since 0.3.2
      #
      # @example
      #   require 'hanami/utils/attributes'
      #
      #   attributes = Hanami::Utils::Attributes.new(a: 1, 'b' => 2, 23 => 'foo')
      #
      #   attributes.get(:a)  # => 1
      #   attributes.get('a') # => 1
      #   attributes[:a]      # => 1
      #   attributes['a']     # => 1
      #
      #   attributes.get(:b)  # => 2
      #   attributes.get('b') # => 2
      #   attributes[:b]      # => 2
      #   attributes['b']     # => 2
      #
      #   attributes.get(23)   # => "foo"
      #   attributes.get('23') # => "foo"
      #   attributes[23]       # => "foo"
      #   attributes['23']     # => "foo"
      #
      #   attributes.get(:unknown)  # => nil
      #   attributes.get('unknown') # => nil
      #   attributes[:unknown]      # => nil
      #   attributes['unknown']     # => nil
      def get(attribute)
        @attributes[attribute.to_s]
      end

      # @since 0.3.4
      alias_method :[], :get

      # Set the given value for the given attribute
      #
      # @param attribute [#to_s] a String or any object that implements #to_s
      # @param value [Object] any value
      #
      # @return [NilClass]
      #
      # @since 0.3.2
      #
      # @example
      #   require 'hanami/utils/attributes'
      #
      #   attributes = Hanami::Utils::Attributes.new
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
      # @return [::Hash]
      #
      # @since 0.3.2
      def to_h
        ::Hash[].tap do |result|
          @attributes.each do |k, v|
            result[k] = _read_value(v)
          end
        end
      end

      private

      # @since 0.4.1
      # @api private
      def _read_value(value)
        case val = value
        when ::Hash, ::Hanami::Utils::Hash, ->(v) { v.respond_to?(:hanami_nested_attributes?) }
          val.to_h
        else
          val
        end
      end
    end
  end
end
