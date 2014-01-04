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
            push Callback.fabricate(c)
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

      # Proc callback
      class Callback
        attr_reader :callback

        def self.fabricate(callback)
          if callback.respond_to?(:call)
            new(callback)
          else
            MethodCallback.new(callback)
          end
        end

        def initialize(callback)
          @callback = callback
        end

        def call(context, *args)
          context.instance_exec(*args, &callback)
        end
      end

      # Method callback
      class MethodCallback < Callback
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
