# frozen_string_literal: true

require "hanami/utils/io"

class IOTest
  TEST_CONSTANT = "initial".freeze
end

RSpec.describe Hanami::Utils::IO do
  describe ".silence_warnings" do
    it "lowers verbosity of stdout" do
      expect do
        Hanami::Utils::IO.silence_warnings do
          IOTest::TEST_CONSTANT = "redefined".freeze
        end
      end.to output(eq("")).to_stderr
    end
  end
end
