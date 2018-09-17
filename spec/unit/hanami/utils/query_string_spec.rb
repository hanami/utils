require "hanami/utils/query_string"
require "bigdecimal"

RSpec.describe Hanami::Utils::QueryString do
  describe ".call" do
    context "when ::Hash" do
      it "serializes input" do
        expect(described_class.call(foo: 1, bar: nil, greet: "hello, world")).to eq(%(foo=1,bar=nil,greet="hello, world"))
      end
    end

    context "when nil" do
      it "serializes input" do
        expect(described_class.call(nil)).to eq("")
      end
    end

    context "Ruby types" do
      it "serializes nil" do
        expect(described_class.call(foo: nil)).to eq("foo=nil")
      end

      it "serializes string" do
        expect(described_class.call(foo: "bar")).to eq(%(foo="bar"))
      end

      it "serializes number" do
        expect(described_class.call(foo: 1)).to eq("foo=1")
        expect(described_class.call(foo: 3.14)).to eq("foo=3.14")
      end

      it "serializes string representation of a number" do
        expect(described_class.call(foo: "1")).to eq(%(foo="1"))
        expect(described_class.call(foo: "3.14")).to eq(%(foo="3.14"))
      end
    end
  end
end
