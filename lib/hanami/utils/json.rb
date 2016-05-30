begin
  require 'multi_json'
rescue LoadError
  require 'json'
end

module Hanami
  module Utils
    # JSON wrapper
    #
    # If you use MultiJson gem this wrapper will use it.
    # Otherwise - JSON std lib.
    #
    # @since x.x.x
    module Json
      # rubocop:disable Style/ClassVars
      if defined?(MultiJson)
        @@engine    = MultiJson
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
      # @since x.x.x
      def self.load(payload)
        @@engine.load(payload)
      end

      # Dump the given object into a JSON payload
      #
      # @param object [Object] any object
      #
      # @return [String] the result of the dumping process
      #
      # @since x.x.x
      def self.dump(object)
        @@engine.dump(object)
      end
    end
  end
end
