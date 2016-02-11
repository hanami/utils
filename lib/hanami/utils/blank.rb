require 'hanami/utils/inflector'

module Hanami
  module Utils
    # Checks for blank
    # @since x.x.x
    class Blank
      # Matcher for blank strings
      #
      # @since x.x.x
      # @api private
      STRING_MATCHER = /\A[[:space:]]*\z/.freeze

      # Checks object is blank
      #
      # @example Basic Usage
      #   require 'hanami/utils/blank'
      #
      #   Hanami::Utils::Blank.blank?(Hanami::Utils::String.new('')) # => true
      #   Hanami::Utils::Blank.blank?('  ')                          # => true
      #   Hanami::Utils::Blank.blank?(nil)                           # => true
      #   Hanami::Utils::Blank.blank?(Hanami::Utils::Hash.new({}))   # => true
      #   Hanami::Utils::Blank.blank?(true)                          # => false
      #   Hanami::Utils::Blank.blank?(1)                             # => false
      #
      # @param object the argument
      #
      # @return [TrueClass,FalseClass]
      #
      # @since x.x.x
      def self.blank?(object)
        case object
        when String, ::String
          STRING_MATCHER === object
        when Hash, ::Hash, ::Array
          object.empty?
        when TrueClass, Numeric
          false
        when FalseClass, NilClass
          true
        else
          object.respond_to?(:empty?) ? !!object.empty? : !self
        end
      end
    end
  end
end
