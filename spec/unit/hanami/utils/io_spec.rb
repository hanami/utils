require 'hanami/utils/io'

class IOTest
  TEST_CONSTANT = 'initial'.freeze

  def self.print_error
    Kernel.warn('Hey look at me!')
  end
end

RSpec.describe Hanami::Utils::IO do
  describe '.silence_warnings' do
    it 'lowers verbosity of stdout' do
      expect do
        Hanami::Utils::IO.silence_warnings do
          IOTest::TEST_CONSTANT = 'redefined'.freeze
        end
      end.to output(eq('')).to_stderr
    end
  end

  describe '.silence_stderr' do
    it 'sets $stderr to File::Null' do
      expect do
        Hanami::Utils::IO.silence_stderr do
          IOTest.print_error
        end
      end.to output(eq('')).to_stderr
    end
  end
end
