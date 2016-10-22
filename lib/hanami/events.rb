require 'hanami/utils/class_attribute'
begin
  require 'concurrent'
rescue LoadError
  raise "Cannot find `concurrent-ruby' gem, please install it and retry."
end

module Hanami
  # Event framework for Hanami
  #
  # @since x.x.x
  module Events
    # Backends for Hanami::Events
    #
    # @since x.x.x
    module Backends
      # Memory backend for Hanami::Events
      #
      # @since x.x.x
      # @api private
      class Memory
        # Instantiate a new memory backend
        #
        # @return [Hanami::Events::Backends::Memory] a new instance
        #
        # @since x.x.x
        # @api private
        def initialize
          @topics = Concurrent::Map.new { |h, k| h[k] = Concurrent::Array.new }
        end

        # Subscribe to a topic
        #
        # @param topic [String,Symbol] the topic
        # @param subscriber [#call] the subscriber
        #
        # @since x.x.x
        # @api private
        def subscribe(topic, subscriber)
          topics[topic.to_sym].push(subscriber)
        end

        # Broadcast an event for a given topic
        #
        # @param topic [String,Symbol] the topic
        # @param event [Hanami::Events::Event] the event
        #
        # @since x.x.x
        # @api private
        def broadcast(topic, event)
          topics[topic.to_sym].each do |subscriber|
            subscriber.call(event)
          end
        end

        private

        # @since x.x.x
        # @api private
        attr_reader :topics
      end
    end

    # Broadcasted Event
    #
    # @since x.x.x
    class Event
      # Instantiate a new event
      #
      # @param [#to_hash,#to_h] the payload
      #
      # @return [Hanami::Events::Event] a new instance
      #
      # @since x.x.x
      # @api private
      def initialize(payload)
        @payload = Utils::Hash.new(payload).symbolize!.freeze
      end

      # Return the value associated to the given key
      #
      # @param [Symbol] the key
      #
      # @return [Object,NilClass] the value, if present
      #
      # @since x.x.x
      def [](key)
        @payload[key]
      end
    end

    include Utils::ClassAttribute

    # Support multiple backend for the future.
    #
    # For now the only backend is Hanami::Events::Backends::Memory
    #
    # @since x.x.x
    # @api private
    class_attribute :backend
    self.backend = Backends::Memory.new

    # Subscribe to a topic
    #
    # @param topic [String,Symbol] the topic
    # @param subscriber [#call] the subscriber (object)
    # @param blk [Proc] the subscriber (proc)
    #
    # @since x.x.x
    #
    # @example Subscribe With An Object
    #   require 'hanami/events'
    #
    #   class WelcomeMailer
    #     def call(event)
    #       # do something with event
    #     end
    #   end
    #
    #   Hanami::Events.subscribe('welcome', WelcomeMailer.new)
    #
    # @example Subscribe With A Proc
    #   require 'hanami/events'
    #
    #   Hanami::Events.subscribe('welcome') do |event|
    #     # do something with event
    #   end
    def self.subscribe(topic, subscriber = nil, &blk)
      backend.subscribe(topic, subscriber || blk)
    end

    # Broadcast an event for a given topic
    #
    # @param topic [String,Symbol] the topic
    # @param event [#to_hash,#to_h] the payload
    #
    # @since x.x.x
    #
    # @example
    #   require 'hanami/events'
    #
    #   Hanami::Events.subscribe('signup') do |event|
    #     puts "Welcome #{event[:user].name}"
    #   end
    #
    #   user = User.new(name: "Luca")
    #   Hanami::Events.broadcast('signup', user: user)
    #
    #     # => "Welcome Luca"
    def self.broadcast(topic, payload)
      backend.broadcast(topic, Event.new(payload))
    end

    private

    # Broadcast an event for a given topic
    #
    # @param topic [String,Symbol] the topic
    # @param event [#to_hash,#to_h] the payload
    #
    # @since x.x.x
    #
    # @see Hanami::Events.broadcast
    #
    # @example
    #   require 'hanami/events'
    #
    #   class Signup
    #     include Hanami::Events
    #
    #     def call(params)
    #       user = User.new(params)
    #       broadcast('signup', user: user)
    #     end
    #   end
    def broadcast(topic, payload)
      Events.broadcast(topic, payload)
    end
  end
end
