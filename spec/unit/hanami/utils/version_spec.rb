# frozen_string_literal: true

RSpec.describe "Hanami::Utils::VERSION" do
  it "exposes version" do
    expect(Hanami::Utils::VERSION).to eq("1.3.6")
  end
end
