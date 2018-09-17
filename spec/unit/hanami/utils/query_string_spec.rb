require "hanami/utils/query_string"

RSpec.describe Hanami::Utils::QueryString do
  describe ".call" do
    context "when ::Hash" do
      it "serializes input" do
        expect(described_class.call(foo: "1", bar: nil, baz: "hello")).to eq("foo=1,bar=,baz=hello")
      end
    end

    context "when nil" do
      it "serializes input" do
        expect(described_class.call(nil)).to eq("")
      end
    end
  end
end
