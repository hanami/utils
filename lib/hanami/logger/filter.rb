# frozen_string_literal: true

require "logger"

module Hanami
  class Logger < ::Logger
    # Filtering logic
    #
    # @since 1.1.0
    # @api private
    class Filter
      FILTERED_VALUE = "[FILTERED]"

      # @since 1.1.0
      # @api private
      def initialize(filters = [])
        @filters = filters
      end

      # @since 1.1.0
      # @api private
      def call(original_hash)
        filtered_hash = _filtered_keys(original_hash).each_with_object({}) do |key, memo|
          *keys, last = _actual_keys(original_hash, key.split("."))

          keys.inject(memo) do |hash, k|
            hash[k] ||= {}
          end[last] = FILTERED_VALUE
        end

        _deep_merge(original_hash, filtered_hash)
      end

      private

      # @since 1.1.0
      # @api private
      attr_reader :filters

      # This is a simple deep merge to merge the original input
      # with the filtered hash which contains '[FILTERED]' string.
      #
      # It only deep-merges if the conflict values are both hashes.
      #
      # @since x.x.x
      # @api private
      def _deep_merge(original_hash, filtered_hash)
        original_hash.merge(filtered_hash) do |_key, original_item, filtered_item|
          if original_item.is_a?(Hash) && filtered_item.is_a?(Hash)
            _deep_merge(original_item, filtered_item)
          elsif filtered_item == FILTERED_VALUE
            filtered_item
          else
            original_item
          end
        end
      end

      # @since 1.1.0
      # @api private
      def _filtered_keys(hash)
        _key_paths(hash).select { |key| filters.any? { |filter| key =~ %r{(\.|\A)#{filter}(\.|\z)} } }
      end

      # @since 1.1.0
      # @api private
      def _key_paths(hash, base = nil)
        hash.inject([]) do |results, (k, v)|
          results + (_key_paths?(v) ? _key_paths(v, _build_path(base, k)) : [_build_path(base, k)])
        end
      end

      # @since 1.1.0
      # @api private
      def _build_path(base, key)
        [base, key.to_s].compact.join(".")
      end

      # @since 1.1.0
      # @api private
      def _actual_keys(hash, keys)
        search_in = hash

        keys.inject([]) do |res, key|
          correct_key = search_in.key?(key.to_sym) ? key.to_sym : key
          search_in = search_in[correct_key]
          res + [correct_key]
        end
      end

      # Check if the given value can be iterated (`Enumerable`) and that isn't a `File`.
      # This is useful to detect closed `Tempfiles`.
      #
      # @since 1.3.5
      # @api private
      #
      # @see https://github.com/hanami/utils/pull/342
      def _key_paths?(value)
        value.is_a?(Enumerable) && !value.is_a?(File)
      end
    end
  end
end
