module Lotus
  module Utils
    # Before and After callbacks
    module Callbacks
      # Series of callbacks to be executed
      class Chain < ::Array
        # Adds the given callbacks to the chain
        #
        # @param callbacks [Array] one or multiple callbacks to add
        # @param blk [Proc] an optional block to be added
        #
        # @return [void]
        #
        # @see #run
        # @see Lotus::Utils::Callbacks::Callback
        # @see Lotus::Utils::Callbacks::MethodCallback
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #
        #   # Add a Proc to be used as a callback, it will be wrapped by `Callback`
        #   # The optional argument(s) correspond to the one passed when invoked the chain with `run`.
        #   chain.add { Authenticator.authenticate! }
        #   chain.add {|params| ArticleRepository.find(params[:id]) }
        #
        #   # Add a Symbol as a reference to a method name that will be used as a callback.
        #   # It will wrapped by `MethodCallback`
        #   # If the #notificate method accepts some argument(s) they should be passed when `run` is invoked.
        #   chain.add :notificate
        def add(*callbacks, &blk)
          callbacks.push blk if block_given?
          callbacks.each do |c|
            push Factory.fabricate(c)
          end

          uniq!
        end

        # Runs all the callbacks in the chain.
        # The only two ways to stop the execution are: `raise` or `throw`.
        #
        # @param context [Object] the context where we want the chain to be invoked.
        # @param args [Array] the arguments that we want to pass to each single callback.
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   class Action
        #     private
        #     def authenticate!
        #     end
        #
        #     def set_article(params)
        #     end
        #   end
        #
        #   action = Action.new
        #   params = Hash[id: 23]
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #   chain.add :authenticate!, :set_article
        #
        #   chain.run(action, params)
        #
        #   # `params` will only be passed as #set_article argument, because it has an arity greater than zero
        #
        #
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #
        #   chain.add do
        #     # some authentication logic
        #   end
        #
        #   chain.add do |params|
        #     # some other logic that requires `params`
        #   end
        #
        #   chain.run(action, params)
        #
        #   Those callbacks will be invoked within the context of `action`.
        def run(context, *args)
          each do |callback|
            callback.call(context, *args)
          end
        end
      end

      # Callback factory
      class Factory
        # Instantiates a `Callback` according to if it responds to #call.
        #
        # @param callback [Object] the object that needs to be wrapped
        #
        # @return [Callback, MethodCallback]
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   callable = Proc.new{} # it responds to #call
        #   method   = :upcase    # it doesn't responds to #call
        #
        #   Lotus::Utils::Callbacks::Factory.fabricate(callable).class
        #     # => Lotus::Utils::Callbacks::Callback
        #
        #   Lotus::Utils::Callbacks::Factory.fabricate(method).class
        #     # => Lotus::Utils::Callbacks::MethodCallback
        def self.fabricate(callback)
          if callback.respond_to?(:call)
            Callback.new(callback)
          else
            MethodCallback.new(callback)
          end
        end
      end

      # Proc callback
      # It wraps an object that responds to #call
      class Callback
        attr_reader :callback

        # Initialize by wrapping the given callback
        #
        # @param callback [Object] the original callback that needs to be wrapped
        #
        # @return [Callback] self
        def initialize(callback)
          @callback = callback
        end

        # Executes the callback within the given context and passing the given arguments.
        #
        # @param context [Object] the context within we want to execute the callback.
        # @param args [Array] an array of arguments that will be available within the execution.
        #
        # @return [void, Object] It may return a value, it depends on the callback.
        #
        # @see Lotus::Utils::Callbacks::Chain#run
        def call(context, *args)
          context.instance_exec(*args, &callback)
        end
      end

      # Method callback
      # It wraps a symbol or a string representing a method name that is implemented by the context within it will be called.
      class MethodCallback < Callback
        # Executes the callback within the given context and eventually passing the given arguments.
        # Those arguments will be passed according to the arity of the target method.
        #
        # @param context [Object] the context within we want to execute the callback.
        # @param args [Array] an array of arguments that will be available within the execution.
        #
        # @return [void, Object] It may return a value, it depends on the callback.
        #
        # @see Lotus::Utils::Callbacks::Chain#run
        def call(context, *args)
          method = context.method(callback)

          if method.parameters.any?
            method.call(*args)
          else
            method.call
          end
        end

        protected
        def hash
          callback.hash
        end

        def eql?(other)
          hash == other.hash
        end
      end
    end
  end
end
