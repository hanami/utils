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
    if defined? MultiJson
      Json = MultiJson
      Json::ParserError = MultiJson::ParseError
    else
      Json = ::JSON
    end
  end
end
