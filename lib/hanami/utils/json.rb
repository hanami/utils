begin
  require 'multi_json'
rescue LoadError
  require 'json'
end

require 'hanami/utils/deprecation'

module Hanami
  module Utils
    # JSON wrapper
    #
    # If you use MultiJson gem this wrapper will use it.
    # Otherwise - JSON std lib.
    #
    # @since 0.8.0
    module Json
      # MultiJson adapter
      #
      # @since 0.9.1
      # @api private
      class MultiJsonAdapter
        # @since 0.9.1
        # @api private
        def parse(payload)
          MultiJson.load(payload)
        end

        # FIXME: remove this alias, when Hanami::Utils::Json.load will be removed
        #
        # @since 0.9.1
        # @api private
        alias load parse

        # @since 0.9.1
        # @api private
        def dump(object)
          MultiJson.dump(object)
        end
      end

      # rubocop:disable Style/ClassVars
      if defined?(MultiJson)
        @@engine    = MultiJsonAdapter.new
        ParserError = MultiJson::ParseError
      else
        @@engine    = ::JSON
        ParserError = ::JSON::ParserError
      end
      # rubocop:enable Style/ClassVars

      # Load the given JSON payload into Ruby objects.
      #
      # @param payload [String] a JSON payload
      #
      # @return [Object] the result of the loading process
      #
      # @raise [Hanami::Utils::Json::ParserError] if the paylod is invalid
      #
      # @since 0.8.0
      #
      # @deprecated Use {#parse} instead
      def self.load(payload)
        Hanami::Utils::Deprecation.new("`Hanami::Utils::Json.load' is deprecated, please use `Hanami::Utils::Json.parse'")
        @@engine.load(payload)
      end

      # Parse the given JSON paylod
      #
      # @param payload [String] a JSON payload
      #
      # @return [Object] the result of the loading process
      #
      # @raise [Hanami::Utils::Json::ParserError] if the paylod is invalid
      #
      # @since 0.9.1
      def self.parse(payload)
        @@engine.parse(payload)
      end

      # Dump the given object into a JSON payload
      #
      # @param object [Object] any object
      #
      # @return [String] the result of the dumping process
      #
      # @since 0.8.0
      def self.dump(object)
        @@engine.dump(object)
      end
    end
  end
end
