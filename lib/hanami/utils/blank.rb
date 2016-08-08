module Hanami
  module Utils
    # Checks for blank
    # @since 0.8.0
    class Blank
      # Matcher for blank strings
      #
      # @since 0.8.0
      # @api private
      STRING_MATCHER = /\A[[:space:]]*\z/

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
      # @since 0.8.0
      def self.blank?(object) # rubocop:disable Metrics/MethodLength
        case object
        when String, ::String
          STRING_MATCHER === object # rubocop:disable Style/CaseEquality
        when Hash, ::Hash, ::Array
          object.empty?
        when TrueClass, Numeric
          false
        when FalseClass, NilClass
          true
        else
          object.respond_to?(:empty?) ? object.empty? : !self
        end
      end
    end
  end
end
