require 'lotus/utils'

module Lotus
  module Utils
    # Prints a deprecation warning when initialized
    #
    # @since x.x.x
    class Deprecation
      # Initialize a deprecation message and prints it to standard error.
      #
      # @param message [#to_s] a deprecation message
      #
      # @since x.x.x
      #
      # @example Direct usage
      #   require 'lotus/utils/deprecation'
      #
      #   class Engine
      #     def old_method
      #       Lotus::Utils::Deprecation.new('old_method is deprecated, please use new_method')
      #       new_method
      #     end
      #
      #     def new_method
      #       puts 'started'
      #     end
      #   end
      #
      #   Engine.new.old_method
      #     # => old_method is deprecated, please use new_method - called from: test.rb:14:in `<main>'.
      #     # => started
      #
      # @example Indirect usage
      #   require 'lotus/utils/deprecation'
      #
      #   class Engine
      #     def old_method
      #       Lotus::Utils::Deprecation.new('old_method is deprecated, please use new_method')
      #       new_method
      #     end
      #
      #     def new_method
      #       puts 'started'
      #     end
      #   end
      #
      #   class Car
      #     def initialize
      #       @engine = Engine.new
      #     end
      #
      #     def start
      #       @engine.old_method
      #     end
      #   end
      #
      #   Car.new.start
      #     # => old_method is deprecated, please use new_method - called from: test.rb:20:in `start'.
      #     # => started
      def initialize(message)
        stack_index = Utils.jruby? ? 1 : 2
        ::Kernel.warn("#{ message } - called from: #{ caller[stack_index] }.")
      end
    end
  end
end
