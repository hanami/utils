# frozen_string_literal: true

require "hanami/middleware"

RSpec.describe Hanami::Middleware do
  describe "Error" do
    it "inherits from ::StandardError" do
      expect(Hanami::Middleware::Error.superclass).to eq(StandardError)
    end
  end
end
