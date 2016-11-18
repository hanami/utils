require 'test_helper'

describe Hanami::Utils::VERSION do
  it 'exposes version' do
    Hanami::Utils::VERSION.must_equal '0.9.1'
  end
end
