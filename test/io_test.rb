require 'test_helper'
require 'hanami/utils/io'

class IOTest
  TEST_CONSTANT = 'initial'
end

describe Hanami::Utils::IO do
  describe '.silence_warnings' do
    it 'lowers verbosity of stdout' do
      _, err = capture_io do
        Hanami::Utils::IO.silence_warnings do
          IOTest::TEST_CONSTANT = 'redefined'
        end
      end

      err.must_equal ""
    end
  end
end
