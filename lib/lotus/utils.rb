require 'lotus/utils/version'

module Lotus
  # Ruby core extentions and Lotus utilities
  #
  # @since 0.1.0
  module Utils
    # @since 0.3.1
    # @api private
    LOTUS_JRUBY = 'java'.freeze

    # @since 0.3.1
    # @api private
    LOTUS_RUBINIUS = 'rbx'.freeze

    # Checks if the current VM is JRuby
    #
    # @return [TrueClass,FalseClass] return if the VM is JRuby or not
    #
    # @since 0.3.1
    # @api private
    def self.jruby?
      RUBY_PLATFORM == LOTUS_JRUBY
    end

    # Checks if the current VM is Rubinius
    #
    # @return [TrueClass,FalseClass] return if the VM is Rubinius or not
    #
    # @since 0.3.1
    # @api private
    def self.rubinius?
      RUBY_ENGINE == LOTUS_RUBINIUS
    end
  end
end
