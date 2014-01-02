require 'test_helper'
require 'lotus/utils/class_attribute'

describe Lotus::Utils::ClassAttribute do
  before do
    class ClassAttributeTest
      include Lotus::Utils::ClassAttribute
      class_attribute :callbacks, :functions, :values
      self.callbacks = [:a]
      self.values    = [1]
    end

    class SubclassAttributeTest < ClassAttributeTest
      class_attribute :subattribute
      self.functions    = [:x, :y]
      self.subattribute = 42
    end

    class SubSubclassAttributeTest < SubclassAttributeTest
    end

    class Vehicle
      include Lotus::Utils::ClassAttribute
      class_attribute :engines, :wheels

      self.engines = 0
      self.wheels  = 0
    end

    class Car < Vehicle
      self.engines = 1
      self.wheels  = 4
    end

    class Airplane < Vehicle
      self.engines = 4
      self.wheels  = 16
    end

    class SmallAirplane < Airplane
      self.engines = 2
      self.wheels  = 8
    end
  end

  after do
    [:ClassAttributeTest,
     :SubclassAttributeTest,
     :SubSubclassAttributeTest,
     :Vehicle,
     :Car,
     :Airplane,
     :SmallAirplane].each do |const|
      Object.send :remove_const, const
    end
  end

  it 'sets the given value' do
    ClassAttributeTest.callbacks.must_equal([:a])
  end

  it 'the value it is inherited by subclasses' do
    SubclassAttributeTest.callbacks.must_equal([:a])
  end

  it 'if the superclass value changes it does not affects subclasses' do
    ClassAttributeTest.functions = [:y]
    SubclassAttributeTest.functions.must_equal([:x, :y])
  end

  it 'if the subclass value changes it does not affects superclass' do
    SubclassAttributeTest.values = [3,2]
    ClassAttributeTest.values.must_equal([1])
  end

  # it 'if the subclass value changes it affects subclasses' do
  #   values = [3,2]
  #   SubclassAttributeTest.values = values
  #   SubclassAttributeTest.values.must_equal(values)
  #   SubSubclassAttributeTest.values.must_equal(values)
  # end

  it 'if the subclass defines an attribute it should not be available for the superclass' do
    -> { ClassAttributeTest.subattribute }.must_raise(NoMethodError)
  end

  it 'if the subclass defines an attribute it should be available for its subclasses' do
    SubSubclassAttributeTest.subattribute.must_equal 42
  end

  it 'preserves values within the inheritance chain' do
    Vehicle.engines.must_equal 0
    Vehicle.wheels.must_equal  0

    Car.engines.must_equal 1
    Car.wheels.must_equal  4

    Airplane.engines.must_equal 4
    Airplane.wheels.must_equal  16

    SmallAirplane.engines.must_equal 2
    SmallAirplane.wheels.must_equal  8
  end
end
