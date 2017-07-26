require 'hanami/utils/class_attribute'

module Hanami
  # Event framework for Hanami
  module Events
    include Utils::ClassAttribute
    class_attribute :backend

    def self.subscribe(event_type, subscriber = nil, &blk)
      backend.subscribe(event_type, subscriber || blk)
    end

    def self.broadcast(event_type, payload)
      backend.broadcast(event_type, payload)
    end
  end
end

begin
  require 'hanami/events/backends/wisper'
rescue LoadError
  raise "Couldn't find `wisper` gem. Please, add `gem 'wisper', '2.0.0'` to Gemfile in order to use `Hanami::Events`"
end
