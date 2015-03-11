require 'lotus/utils/basic_object'
require 'lotus/utils/hash'

module Lotus
  # Lotus Interactor
  #
  # @since x.x.x
  module Interactor
    # Result of an operation
    #
    # @since x.x.x
    class Result < Utils::BasicObject
      # Concrete methods
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Interactor::Result#respond_to_missing?
      METHODS = {initialize: true, success?: true, fail!: true, prepare!: true}.freeze

      # Initialize a new result
      #
      # @param payload [Hash] a payload to carry on
      #
      # @return [Lotus::Interactor::Result]
      #
      # @since x.x.x
      # @api private
      def initialize(payload = {})
        @payload = _payload(payload)
        @success = true
      end

      # Check if the current status is successful
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since x.x.x
      def success?
        @success
      end

      # Force the status to be a failure
      #
      # @since x.x.x
      def fail!
        @success = false
      end

      # Prepare the result before to be returned
      #
      # @param payload [Hash] an updated payload
      #
      # @since x.x.x
      # @api private
      def prepare!(payload)
        @payload.merge!(_payload(payload))
        self
      end

      protected
      # @since x.x.x
      # @api private
      def method_missing(m, *)
        @payload.fetch(m) { super }
      end

      # @since x.x.x
      # @api private
      def respond_to_missing?(method_name, include_all)
        method_name = method_name.to_sym
        METHODS[method_name] || @payload.key?(method_name)
      end

      # @since x.x.x
      # @api private
      def _payload(payload)
        Utils::Hash.new(payload).symbolize!
      end

      # @since x.x.x
      # @api private
      def __inspect
        " @success=#{ @success } @payload=#{ @payload.inspect }"
      end
    end

    # Override for <tt>Module#included</tt>.
    #
    # @since x.x.x
    # @api private
    def self.included(base)
      super

      base.class_eval do
        prepend Interface
      end
    end

    # Interactor interface
    #
    # @since x.x.x
    module Interface
      # Initialize an interactor
      #
      # It accepts arbitrary number of arguments.
      # Developers can override it.
      #
      # @param args [Array<Object>] arbitrary number of arguments
      #
      # @return [Lotus::Interactor] the interactor
      #
      # @since x.x.x
      #
      # @example Override #initialize
      #   require 'lotus/interactor'
      #
      #   class UpdateProfile
      #     include Lotus::Interactor
      #
      #     def initialize(person, params)
      #       @person = person
      #       @params = params
      #     end
      #
      #     def call
      #       # ...
      #     end
      #   end
      def initialize(*args)
        super
      ensure
        @_result = ::Lotus::Interactor::Result.new
      end

      # Triggers the operation and return a result.
      #
      # All the instance variables will be available in the result.
      #
      # ATTENTION: This must be implemented by the including class.
      #
      # @return [Lotus::Interactor::Result] the result of the operation
      #
      # @raise [NoMethodError] if this isn't implemented by the including class.
      #
      # @example Instance variables in result payload
      #   require 'lotus/interactor'
      #
      #   class Signup
      #     def initialize(params)
      #       @params = params
      #       @user   = User.new(@params)
      #       @foo    = 'bar'
      #     end
      #
      #     def call
      #       @user = UserRepository.persist(@user)
      #     end
      #   end
      #
      #   result = Signup.new(name: 'Luca').call
      #   result.success? # => true
      #
      #   result.user   # => #<User:0x007fa311105778 @id=1 @name="Luca">
      #   result.params # => { :name=>"Luca" }
      #   result.foo    # => "Bar"
      #
      # @example Failed precondition
      #   require 'lotus/interactor'
      #
      #   class Signup
      #     def initialize(params)
      #       @params = params
      #       @user   = User.new(@params)
      #     end
      #
      #     # THIS WON'T BE INVOKED BECAUSE #valid? WILL RETURN false
      #     def call
      #       @user = UserRepository.persist(@user)
      #     end
      #
      #     private
      #     def valid?
      #       @params.valid?
      #     end
      #   end
      #
      #   result = Signup.new(name: nil).call
      #   result.success? # => false
      #
      #   result.user   # => #<User:0x007fa311105778 @id=nil @name="Luca">
      #
      # @example Bad usage
      #   require 'lotus/interactor'
      #
      #   class Signup
      #     include Lotus::Interactor
      #
      #     # Method #call is not defined
      #   end
      #
      #   Signup.new.call # => NoMethodError
      def call
        _call { super }
      end
    end

    private
    # Check if proceed with <tt>#call</tt> invokation.
    # By default it returns <tt>true</tt>.
    #
    # Developers can override it.
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @since x.x.x
    def valid?
      true
    end

    # Fail and interrupt the current flow.
    #
    # @since x.x.x
    #
    # @example
    #   require 'lotus/interactor'
    #
    #   class CreateEmailTest
    #     include Lotus::Interactor
    #
    #     def initialize(params)
    #       @params     = params
    #       @email_test = EmailTest.new(@params)
    #     end
    #
    #     def call
    #       persist_email_test!
    #       capture_screenshot!
    #     end
    #
    #     private
    #     def persist_email_test!
    #       @email_test = EmailTestRepository.persist(@email_test)
    #     end
    #
    #     # IF THIS RAISES AN EXCEPTION WE FORCE A FAILURE
    #     def capture_screenshot!
    #       Screenshot.new(@email_test).capture!
    #     rescue
    #       fail!
    #     end
    #   end
    #
    #   result = CreateEmailTest.new(account_id: 1).call
    #   result.success? # => false
    def fail!
      @_result.fail!
      throw :fail
    end

    # @since x.x.x
    # @api private
    def _call
      catch :fail do
        _validate!
        yield
      end

      _prepare!
    end

    # @since x.x.x
    # @api private
    def _validate!
      fail! unless valid?
    end

    # @since x.x.x
    # @api private
    def _prepare!
      @_result.prepare!(_instance_variables)
    end

    # @since x.x.x
    # @api private
    def _instance_variables
      Hash[].tap do |result|
        instance_variables.each do |iv|
          name = iv.to_s.sub(/\A@/, '')
          next if name.match(/\A_/)

          result[name.to_sym] = instance_variable_get(iv)
        end
      end
    end
  end
end
