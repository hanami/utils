require 'test_helper'
require 'lotus/utils/property'

class MethodProperty
  include Lotus.property(:word) { @word.capitalize }
end

class ModuleProperty
  include Lotus::Utils::Property.new(:word) { @word.capitalize }
end

describe Lotus::Utils::Property do
  before do
    @property = MethodProperty.new
  end
  
  it 'sets instance variable in writer mode and calls block in reader mode' do
    @property.word('hello')
    @property.word.must_equal 'Hello'
  end
end

describe Lotus::Utils::Property do
  before do
    @property = ModuleProperty.new
  end
  
  it 'sets instance variable in writer mode and calls block in reader mode' do
    @property.word('hello')
    @property.word.must_equal 'Hello'
  end
end