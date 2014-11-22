require 'test_helper'

describe Lotus::Utils::VERSION do
  it 'exposes version' do
    Lotus::Utils::VERSION.must_equal '0.3.1'
  end
end
