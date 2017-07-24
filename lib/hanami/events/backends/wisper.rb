require 'wisper'

module Hanami
  module Events
    # Backends for Hanami::Events
    module Backends
      # Memory backend for Hanami::Events
      class Wisper
        include ::Wisper::Publisher

        def subscribe(event_type, subscriber)
          ::Wisper.subscribe(subscriber, on: event_type, with: :call)
        end

        def broadcast(*args)
          super
        end
      end
    end
  end
end

Hanami::Events.backend = Hanami::Events::Backends::Wisper.new
Hanami::Events.include(::Wisper::Publisher)
