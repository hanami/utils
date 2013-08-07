require 'test_helper'

describe Lotus::Utils::VERSION do
  it 'exposes version' do
    Lotus::Utils::VERSION.must_equal '0.0.1'
  end
end
