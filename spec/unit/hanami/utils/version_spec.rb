RSpec.describe "Hanami::Utils::VERSION" do
  it "exposes version" do
    expect(Hanami::Utils::VERSION).to eq("1.2.0.beta1")
  end
end
