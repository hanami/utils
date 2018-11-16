# frozen_string_literal: true

require "hanami/utils/deprecation"

module Hanami
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
      #   require 'hanami/utils/class'
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
      #   Hanami::Utils::Class.load!('App::Service') # => App::Service
      #   Hanami::Utils::Class.load!(App::Service)   # => App::Service
      #
      #   # with explicit namespace
      #   Hanami::Utils::Class.load!('Service', App) # => App::Service
      #
      #   # with missing constant
      #   Hanami::Utils::Class.load!('Unknown') # => raises NameError
      def self.load!(name, namespace = Object)
        namespace.const_get(name.to_s, false)
      end

      # Loads a class for the given name, only if it's defined.
      #
      # @param name [String, Class] the specific class name
      # @param namespace [Class, Module] the Ruby namespace where we want to perform the lookup.
      # @return [Class, Module, NilClass] the Ruby constant, or nil if not found.
      #
      # @since 0.8.0
      #
      # @example
      #   require 'hanami/utils/class'
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
      #   Hanami::Utils::Class.load('App::Service') # => App::Service
      #   Hanami::Utils::Class.load(App::Service)   # => App::Service
      #
      #   # with explicit namespace
      #   Hanami::Utils::Class.load('Service', App) # => App::Service
      def self.load(name, namespace = Object)
        load!(name, namespace) if namespace.const_defined?(name.to_s, false)
      end

      # rubocop:disable Metrics/MethodLength
      def self.tokenize(pattern)
        if match = TOKENIZE_REGEXP.match(pattern) # rubocop:disable Lint/AssignmentInCondition
          pre  = match.pre_match
          post = match.post_match
          tokens = match[1].split(TOKENIZE_SEPARATOR)
          tokens.each do |token|
            yield("#{pre}#{token}#{post}")
          end
        else
          yield(pattern)
        end

        nil
      end
      # rubocop:enable Metrics/MethodLength

      # Regexp for .tokenize
      #
      # @since 1.3.0
      # @api private
      TOKENIZE_REGEXP = /\((.*)\)/.freeze

      # Separator for .tokenize
      #
      # @since 1.3.0
      # @api private
      TOKENIZE_SEPARATOR = "|"
    end
  end
end
