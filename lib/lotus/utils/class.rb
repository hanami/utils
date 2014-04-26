require 'lotus/utils/string'

module Lotus
  module Utils

    module_function

    # See Lotus::Utils::Class.load!
    #
    # Provided as a convenience method to avoid referencing possibly deeply
    # nested methods.
    def load_class!(*args)
      Class.load!(*args)
    end

    # Class utilities
    # @since 0.1.0
    class Class
      # Loads a class for the given string or pattern.
      #
      # @param name [String] the specific class name or pattern for the class that we want to load
      #
      # @param namespace [Class, Module] the Ruby namespace where we want to perform the lookup.
      #
      # @return [Class, Module] the found Ruby constant.
      #
      # @raise [NameError] if no constant can be found.
      #
      # @since 0.1.0
      #
      # @see Lotus::Utils::String#tokenize
      #
      # @example
      #   require 'lotus/utils/class'
      #
      #   module App
      #     module Service
      #       class Endpoint
      #       end
      #     end
      #
      #     class ServiceEndpoint
      #     end
      #   end
      #
      #   # basic usage
      #   Lotus::Utils::Class.load!('App::Service') # => App::Service
      #
      #   # with explicit namespace
      #   Lotus::Utils::Class.load!('Service', App) # => App::Service
      #
      #   # with pattern
      #   Lotus::Utils::Class.load!('App::Service(::Endpoint|Endpoint)') # => App::Service::Endpoint
      #   Lotus::Utils::Class.load!('App::Service(Endpoint|::Endpoint)') # => App::ServiceEndpoint
      #
      #   # with missing constant
      #   Lotus::Utils::Class.load!('Unknown') # => raises NameError
      def self.load!(name, namespace = Object)
        String.new(name).tokenize do |token|
          begin
            return namespace.const_get(token)
          rescue NameError
          end
        end

        raise NameError.new(name)
      end
    end
  end
end
