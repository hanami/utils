require 'test_helper'
require 'lotus/utils/io'

class IOTest
  TEST_CONSTANT = 'initial'
end

describe Lotus::Utils::IO do
  describe '.silence_warnings' do
    it 'lowers verbosity of stdout' do
      begin
        position = STDOUT.tell

        Lotus::Utils::IO.silence_warnings do
          IOTest::TEST_CONSTANT = 'redefined'
        end

        IOTest::TEST_CONSTANT.must_equal('redefined')
        STDOUT.tell.must_equal(position)
      rescue Errno::ESPIPE
        puts 'Skipping this test, IO#tell is not supported in this environment'

        Lotus::Utils::IO.silence_warnings do
          IOTest::TEST_CONSTANT = 'redefined'
        end
      end
    end
  end
end
