# frozen_string_literal: true

require "logger"

module Hanami
  class Logger < ::Logger
    # Filtering logic
    #
    # @since 1.1.0
    # @api private
    class Filter
      # @since 1.1.0
      # @api private
      def initialize(filters = [])
        @filters = filters
      end

      # @since 1.1.0
      # @api private
      def call(hash)
        _filtered_keys(hash).each do |key|
          *keys, last = _actual_keys(hash, key.split("."))
          keys.inject(hash, :fetch)[last] = "[FILTERED]"
        end

        hash
      end

      private

      # @since 1.1.0
      # @api private
      attr_reader :filters

      # @since 1.1.0
      # @api private
      def _filtered_keys(hash)
        _key_paths(hash).select { |key| filters.any? { |filter| key =~ %r{(\.|\A)#{filter}(\.|\z)} } }
      end

      # @since 1.1.0
      # @api private
      def _key_paths(hash, base = nil)
        hash.inject([]) do |results, (k, v)|
          results + (v.is_a?(Enumerable) && !v.is_a?(File) ? _key_paths(v, _build_path(base, k)) : [_build_path(base, k)])
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
    end
  end
end
