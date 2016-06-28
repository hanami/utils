require 'hanami/utils/class'
require 'hanami/utils/class_attribute'
require 'hanami/utils/hash'

module Hanami
  # Configuration for Hanami frameworks
  #
  # @since x.x.x
  # @api private
  class Configuration
    # @since x.x.x
    # @api private
    def self.inherited(klass)
      klass.class_eval do
        include Hanami::Utils::ClassAttribute

        class_attribute :settings
        self.settings = Utils::Hash.new

        extend ClassMethods
      end
    end

    # Class interface
    #
    # @since x.x.x
    # @api private
    module ClassMethods
      def setting(name, default = nil, options = {})
        n = name.to_sym
        settings[name] = default

        define_method(n)        { settings[n] }                 if options.fetch(:reader, true)
        define_method(:"#{n}=") { |value| settings[n] = value } if options.fetch(:writer, true)
      end

      # Find the configuration for the given class.
      #
      # @param base [Class] a controller or an action
      #
      # @return [Hanami::Configuration] the configuration associated to the
      #   given class.
      #
      # @since x.x.x
      # @api private
      #
      # @example
      #   require 'hanami/controller'
      #
      #   module Controllers
      #     include Hanami::Controller
      #
      #     class Show
      #       include Hanami::Action
      #     end
      #   end
      #
      #   Hanami::Controller::Configuration.for(Controllers::Show)
      #     # => will duplicate return Controllers.configuration
      def for(base)
        result = Utils::Class.each_namespace(base) do |const|
          const.respond_to?(:configuration) &&
            const.configuration.is_a?(Hanami::Configuration)
        end

        (result && result.configuration) || new
      end

      # Fabricate a configuration starting from the given argument.
      #
      # If it's an instance of the current class, it returns the given argument.
      # If it's a Hash, it instantiate a new configuration with the given
      # settings.
      #
      # @param configuration [Hanami::Configuration, Hash, Hanami::Utils::Hash]
      #   the configuration
      #
      # @raise [TypeError] in case the given argument not one of the accepted ones
      #
      # @since x.x.x
      # @api private
      def fabricate(configuration)
        case configuration
        when self
          configuration
        else
          new(configuration)
        end
      end
    end

    # Initialize a new instance
    #
    # @param settings [Hash, Hanami::Utils::Hash] optional settings
    #
    # @return [Hanami::Configuration] a new instance
    #
    # @since x.x.x
    # @api private
    def initialize(settings = {})
      @settings = self.class.settings.deep_dup.merge!(settings)
      yield self if block_given?
      self.settings.deep_freeze
      freeze
    end

    # Yields the given block and returns a new instance
    #
    # @param blk [Proc] a configuration block
    #
    # @yieldparam [Hanami::Configuration]
    #
    # @since x.x.x
    # @api private
    def configure(&blk)
      self.class.new(settings.deep_dup, &blk)
    end

    protected

    # @since x.x.x
    # @api private
    attr_reader :settings

    # @since x.x.x
    # @api private
    def duplicate(&blk)
      if frozen?
        configure(&blk)
      else
        yield self
      end
    end
  end
end
