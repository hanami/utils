module Lotus
  module Utils
    # Inheritable class level variable accessors.
    # (see Lotus::Utils::ClassAttribute::ClassMethods)
    module ClassAttribute
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        # Public: Defines a class level accessor for the given attribute(s).
        #
        # A value set for a superclass is automatically available by their
        # subclasses, unless a different value is explicitely set within the
        # inheritance chain.
        #
        # @param attributes [Symbol] a single or multiple attribute name(s)
        #
        # Examples:
        #
        #   require 'lotus/utils/class_attribute'
        #
        #   class Vehicle
        #     include Lotus::Utils::ClassAttribute
        #     class_attribute :engines, :wheels
        #
        #     self.engines = 0
        #     self.wheels  = 0
        #   end
        #
        #   class Car < Vehicle
        #     self.engines = 1
        #     self.wheels  = 4
        #   end
        #
        #   class Airplane < Vehicle
        #     self.engines = 4
        #     self.wheels  = 16
        #   end
        #
        #   class SmallAirplane < Airplane
        #     self.engines = 2
        #     self.wheels  = 8
        #   end
        #
        #   Vehicle.engines # => 0
        #   Vehicle.wheels  # => 0
        #
        #   Car.engines # => 1
        #   Car.wheels  # => 4
        #
        #   Airplane.engines # => 4
        #   Airplane.wheels  # => 16
        #
        #   SmallAirplane.engines # => 2
        #   SmallAirplane.wheels  # => 8
        def class_attribute(*attributes)
          (class << self; self; end).class_eval do
            attr_accessor *attributes
          end

          class_attributes.merge(attributes)
        end

        # Internal: Overrides `Class#inherited`.
        def inherited(subclass)
          class_attributes.each do |attr|
            value = send(attr)
            value = value.dup rescue value
            subclass.send("#{attr}=", value)
          end

          super
        end

        private
        # Internal: accessor for class attributes.
        def class_attributes
          @class_attributes ||= Set.new
        end
      end
    end
  end
end
