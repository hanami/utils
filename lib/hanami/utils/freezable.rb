module Hanami
  module Utils
    # Deep freezing logic
    #
    # @since x.x.x
    # @api private
    module Freezable
      # @since x.x.x
      # @api private
      def self.freeze(value)
        case value
        when Hash, ::Hash
          value.each_value { |v| freeze(v) } && value.freeze
        when Enumerable
          value.each { |v| freeze(v) } && value.freeze
        when Module, Class
          # do nothing
        else
          value.freeze
        end
      end
    end
  end
end
