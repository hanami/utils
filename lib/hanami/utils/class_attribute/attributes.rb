# frozen_string_literal: true

require "hanami/utils/duplicable"
require "concurrent/map"

module Hanami
  module Utils
    module ClassAttribute
      # Class attributes set
      #
      # @since x.x.x
      # @api private
      class Attributes
        # @since x.x.x
        # @api private
        def initialize(attributes: Concurrent::Map.new)
          @attributes = attributes
        end

        # @since x.x.x
        # @api private
        def []=(key, value)
          @attributes[key.to_sym] = value
        end

        # @since x.x.x
        # @api private
        def [](key)
          @attributes.fetch(key, nil)
        end

        # @since x.x.x
        # @api private
        def dup
          attributes = Concurrent::Map.new.tap do |attrs|
            @attributes.each do |key, value|
              attrs[key.to_sym] = Duplicable.dup(value)
            end
          end

          self.class.new(attributes: attributes)
        end
      end
    end
  end
end
