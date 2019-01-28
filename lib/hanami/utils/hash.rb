# frozen_string_literal: true

require "transproc"

module Hanami
  module Utils
    # Hash transformations
    # @since 0.1.0
    module Hash
      extend Transproc::Registry
      import Transproc::HashTransformations

      # Symbolize the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the symbolized hash
      #
      # @since 1.0.1
      #
      # @see .deep_symbolize
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.symbolize("foo" => "bar", "baz" => {"a" => 1})
      #     # => {:foo=>"bar", :baz=>{"a"=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.symbolize(input)
        self[:symbolize_keys].call(input)
      end

      # Deep symbolize the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep symbolized hash
      #
      # @since 1.0.1
      #
      # @see .symbolize
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.deep_symbolize("foo" => "bar", "baz" => {"a" => 1})
      #     # => {:foo=>"bar", :baz=>{a:=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.deep_symbolize(input)
        self[:deep_symbolize_keys].call(input)
      end

      # Stringify the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the stringified hash
      #
      # @since 1.0.1
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   hash = Hanami::Utils::Hash.stringify(foo: "bar", baz: {a: 1})
      #     # => {"foo"=>"bar", "baz"=>{:a=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.stringify(input)
        self[:stringify_keys].call(input)
      end

      # Deeply stringify the given hash
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the deep stringified hash
      #
      # @since 1.1.1
      #
      # @example Basic Usage
      #   require "hanami/utils/hash"
      #
      #   hash = Hanami::Utils::Hash.deep_stringify(foo: "bar", baz: {a: 1})
      #     # => {"foo"=>"bar", "baz"=>{"a"=>1}}
      #
      #   hash.class
      #     # => Hash
      def self.deep_stringify(input) # rubocop:disable Metrics/MethodLength
        input.each_with_object({}) do |(key, value), output|
          output[key.to_s] =
            case value
            when ::Hash
              deep_stringify(value)
            when Array
              value.map do |item|
                item.is_a?(::Hash) ? deep_stringify(item) : item
              end
            else
              value
            end
        end
      end

      # Deep duplicate hash values
      #
      # The output of this function is a shallow duplicate of the input.
      # Any further modification on the input, won't be reflected on the output
      # and viceversa.
      #
      # @param input [::Hash] the input
      #
      # @return [::Hash] the shallow duplicate of input
      #
      # @since 1.0.1
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #
      #   input  = { "a" => { "b" => { "c" => [1, 2, 3] } } }
      #   output = Hanami::Utils::Hash.deep_dup(input)
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3]}}}
      #
      #   output.class
      #     # => Hash
      #
      #
      #
      #   # mutations on input aren't reflected on output
      #
      #   input["a"]["b"]["c"] << 4
      #   output.dig("a", "b", "c")
      #     # => [1, 2, 3]
      #
      #
      #
      #   # mutations on output aren't reflected on input
      #
      #   output["a"].delete("b")
      #   input
      #     # => {"a"=>{"b"=>{"c"=>[1,2,3,4]}}}
      def self.deep_dup(input)
        input.each_with_object({}) do |(k, v), result|
          result[k] = case v
                      when ::Hash
                        deep_dup(v)
                      else
                        v.dup
                      end
        end
      end

      # Deep serialize given object into a `Hash`
      #
      # Please note that the returning `Hash` will use symbols as keys.
      #
      # @param input [#to_hash] the input
      #
      # @return [::Hash] the deep serialized hash
      #
      # @since 1.1.0
      #
      # @example Basic Usage
      #   require 'hanami/utils/hash'
      #   require 'ostruct'
      #
      #   class Data < OpenStruct
      #     def to_hash
      #       to_h
      #     end
      #   end
      #
      #   input = Data.new("foo" => "bar", baz => [Data.new(hello: "world")])
      #
      #   Hanami::Utils::Hash.deep_serialize(input)
      #     # => {:foo=>"bar", :baz=>[{:hello=>"world"}]}
      def self.deep_serialize(input) # rubocop:disable Metrics/MethodLength
        input.to_hash.each_with_object({}) do |(key, value), output|
          output[key.to_sym] =
            case value
            when ->(h) { h.respond_to?(:to_hash) }
              deep_serialize(value)
            when Array
              value.map do |item|
                item.respond_to?(:to_hash) ? deep_serialize(item) : item
              end
            else
              value
            end
        end
      end
    end
  end
end
