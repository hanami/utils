require 'hanami/utils/version'

module Hanami
  # Ruby core extentions and Hanami utilities
  #
  # @since 0.1.0
  module Utils
    # @since 0.3.1
    # @api private
    HANAMI_JRUBY = 'java'.freeze

    # @since 0.3.1
    # @api private
    HANAMI_RUBINIUS = 'rbx'.freeze

    # Checks if the current VM is JRuby
    #
    # @return [TrueClass,FalseClass] return if the VM is JRuby or not
    #
    # @since 0.3.1
    # @api private
    def self.jruby?
      RUBY_PLATFORM == HANAMI_JRUBY
    end

    # Checks if the current VM is Rubinius
    #
    # @return [TrueClass,FalseClass] return if the VM is Rubinius or not
    #
    # @since 0.3.1
    # @api private
    def self.rubinius?
      RUBY_ENGINE == HANAMI_RUBINIUS
    end
  end
end
