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
      self.functions = [:x, :y]
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
end
