# frozen_string_literal: true

require "cgi"

module Hanami
  module Utils
    # URI query string transformations
    #
    # @since 1.2.0
    module QueryString
      # Serialize input into a query string
      #
      # @param input [Object] the input
      #
      # @return [::String] the query string
      #
      # @since 1.2.0
      #
      # TODO: this is a very basic implementation that needs to be expanded
      def self.call(input)
        case input
        when ::Hash
          input.to_a.join("=")
        else
          input.to_s
        end
      end
    end
  end
end
