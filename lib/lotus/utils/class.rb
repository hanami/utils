require 'lotus/utils/string'
require 'lotus/utils/deprecation'

module Lotus
  module Utils
    # Class utilities
    # @since 0.1.0
    class Class
      # Loads a class for the given name.
      #
      # @param name [String, Class] the specific class name
      # @param namespace [Class, Module] the Ruby namespace where we want to perform the lookup.
      # @return [Class, Module] the found Ruby constant.
      #
      # @raise [NameError] if no constant can be found.
      #
      # @since 0.1.0
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
      #   Lotus::Utils::Class.load!(App::Service)   # => App::Service
      #
      #   # with explicit namespace
      #   Lotus::Utils::Class.load!('Service', App) # => App::Service
      #
      #   # with missing constant
      #   Lotus::Utils::Class.load!('Unknown') # => raises NameError
      def self.load!(name, namespace = Object)
        name = name.to_s

        if name.match(/\|/)
          Utils::Deprecation.new("Using Lotus::Utils::Class.load! with a pattern is deprecated, please use Lotus::Utils::Class.load_from_pattern!: #{ name }, #{ namespace }")
          return load_from_pattern!(name, namespace)
        end

        namespace.const_get(name)
      end

      # Loads a class from the given pattern name and namespace
      #
      # @param pattern [String] the class name pattern
      # @param namespace [Class, Module] the Ruby namespace where we want to perform the lookup.
      # @return [Class, Module] the found Ruby constant.
      #
      # @raise [NameError] if no constant can be found.
      #
      # @since 0.3.1
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
      def self.load_from_pattern!(pattern, namespace = Object)
        String.new(pattern).tokenize do |token|
          begin
            return namespace.const_get(token)
          rescue NameError
          end
        end

        full_name = [ (namespace == Object ? nil : namespace), pattern ].compact.join('::')
        raise NameError.new("uninitialized constant #{ full_name }")
      end
    end
  end
end
