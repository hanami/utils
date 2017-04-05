require 'test_helper'

describe Hanami::Utils::VERSION do
  it 'exposes version' do
    Hanami::Utils::VERSION.must_equal '1.0.0'
  end
end
