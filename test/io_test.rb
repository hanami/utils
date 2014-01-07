require 'test_helper'
require 'lotus/utils/io'

class IOTest
  TEST_CONSTANT = 'initial'
end

describe Lotus::Utils::IO do
  describe '.silence_warnings' do
    it 'lowers verbosity of stdout' do
      position = STDOUT.tell

      Lotus::Utils::IO.silence_warnings do
        IOTest::TEST_CONSTANT = 'redefined'
      end

      IOTest::TEST_CONSTANT.must_equal('redefined')
      STDOUT.tell.must_equal(position)
    end
  end
end
