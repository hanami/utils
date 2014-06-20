require 'test_helper'
require 'lotus/utils/property'

class Property
  include Lotus::Utils::Property
  
  property(:word) { @word.capitalize }
end

describe Lotus::Utils::Property do
  before do
    @property = Property.new
  end
  
  it 'sets instance variable in writer mode and calls block in reader mode' do
    @property.word('hello')
    @property.word.must_equal 'Hello'
  end
end
