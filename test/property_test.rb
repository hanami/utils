require 'test_helper'
require 'lotus/utils/property'

class Property
  include Lotus::Utils::Property

  property(:fruit) { @fruit.capitalize }

  def other_fruit=(fruit)
    @fruit = fruit
  end
end

describe Lotus::Utils::Property do
  before do
    @property = Property.new
  end

  describe 'defined with block' do
    it 'sets instance variable in writer mode and calls block in reader mode' do
      @property.fruit('orange')
      @property.fruit.must_equal 'Orange'
    end

    describe 'instance variable already set' do
      before do
        @property.other_fruit = 'banana'
      end

      it 'calls block in reader mode' do
        @property.fruit.must_equal 'Banana'
      end

      it 'sets instance variable in writer mode' do
        @property.fruit('apple')
        @property.fruit.must_equal 'Apple'
      end
    end
  end
end
