module Hanami
  module Utils
    # Safe dup logic
    #
    # @since 0.6.0
    module Duplicable
      # Duplicates the given value.
      #
      # It accepts a block to customize the logic.
      #
      # The following types aren't duped:
      #
      #   * <tt>NilClass</tt>
      #   * <tt>FalseClass</tt>
      #   * <tt>TrueClass</tt>
      #   * <tt>Symbol</tt>
      #   * <tt>Numeric</tt>
      #
      # All the other types are duped via <tt>#dup</tt>
      #
      # @param value [Object] the value to duplicate
      # @param blk [Proc] the optional block to customize the logic
      #
      # @return [Object] the duped value
      #
      # @since 0.6.0
      #
      # @example Basic Usage With Types That Can't Be Duped
      #   require 'hanami/utils/duplicable'
      #
      #   object = 23
      #   puts object.object_id # => 47
      #
      #   result = Hanami::Utils::Duplicable.dup(object)
      #
      #   puts result           # => 23
      #   puts result.object_id # => 47 - Same object, because numbers can't be duped
      #
      # @example Basic Usage With Types That Can Be Duped
      #   require 'hanami/utils/duplicable'
      #
      #   object = "hello"
      #   puts object.object_id # => 70172661782360
      #
      #   result = Hanami::Utils::Duplicable.dup(object)
      #
      #   puts result           # => "hello"
      #   puts result.object_id # => 70172671467020 – Different object
      #
      # @example Custom Logic
      #   require 'hanami/utils/duplicable'
      #   require 'hanami/utils/hash'
      #
      #   hash = { a: 1 }
      #   puts hash.object_id # => 70207105061680
      #
      #   result = Hanami::Utils::Duplicable.dup(hash) do |value|
      #     case value
      #     when Hanami::Utils::Hash
      #       value.deep_dup
      #     when ::Hash
      #       Hanami::Utils::Hash.new(value).deep_dup.to_h
      #     end
      #   end
      #
      #   puts result           # => "{:a=>1}"
      #   puts result.object_id # => 70207105185500 – Different object
      def self.dup(value, &blk)
        case value
        when NilClass, FalseClass, TrueClass, Symbol, Numeric
          value
        when v = blk && blk.call(value)
          v
        else
          value.dup
        end
      end
    end
  end
end
