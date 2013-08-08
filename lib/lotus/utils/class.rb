require 'lotus/utils/string'

module Lotus
  module Utils
    class Class
      def self.load!(string, namespace = Object)
        String.new(string).tokenize do |token|
          begin
            return namespace.const_get(token)
          rescue NameError
          end
        end

        raise NameError.new(string)
      end
    end
  end
end
