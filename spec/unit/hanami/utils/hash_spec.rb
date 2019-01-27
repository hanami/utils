# frozen_string_literal: true

require "bigdecimal"
require "ostruct"
require "hanami/utils/hash"

RSpec.describe Hanami::Utils::Hash do
  describe ".symbolize" do
    it "returns ::Hash" do
      hash = described_class.symbolize("fub" => "baz")

      expect(hash).to be_kind_of(::Hash)
    end

    it "symbolizes keys" do
      hash = described_class.symbolize("fub" => "baz")

      expect(hash).to eq(fub: "baz")
    end

    it "doesn't mutate original input" do
      input = { "fub" => "baz" }
      described_class.symbolize(input)

      expect(input).to eq("fub" => "baz")
    end

    it "doesn't symbolizes nested hashes" do
      hash = described_class.symbolize("nested" => { "key" => "value" })

      expect(hash[:nested].keys).to eq(["key"])
    end
  end

  describe ".deep_symbolize" do
    it "returns ::Hash" do
      hash = described_class.deep_symbolize("fub" => "baz")

      expect(hash).to be_kind_of(::Hash)
    end

    it "symbolize keys" do
      hash = described_class.deep_symbolize("fub" => "baz")

      expect(hash[:fub]).to eq("baz")
      expect(hash.key?("fub")).to be(false)
    end

    it "doesn't mutate original input" do
      input = { "nested" => { "key" => "value" } }
      described_class.deep_symbolize(input)

      expect(input).to eq("nested" => { "key" => "value" })
    end

    it "symbolizes nested hashes" do
      hash = described_class.deep_symbolize("nested" => { "key" => "value" })

      expect(hash[:nested]).to be_kind_of(::Hash)
      expect(hash[:nested][:key]).to eq("value")
    end

    it "symbolizes deep nested hashes" do
      hash = described_class.deep_symbolize("nested1" => { "nested2" => { "nested3" => { "key" => 1 } } })

      expect(hash.keys).to eq([:nested1])

      hash1 = hash[:nested1]
      expect(hash1).to be_kind_of(::Hash)
      expect(hash1.keys).to eq([:nested2])

      hash2 = hash1[:nested2]
      expect(hash2).to be_kind_of(::Hash)
      expect(hash2.keys).to eq([:nested3])

      hash3 = hash2[:nested3]
      expect(hash3).to be_kind_of(::Hash)
      expect(hash3.keys).to eq([:key])

      expect(hash3[:key]).to eq(1)
    end

    it "symbolizes arrays of hashes" do
      hash = described_class.deep_symbolize("books" => [{ "title" => "Hello Ruby" }, { "title" => "Hello Hanami" }])
      expect(hash).to eq(books: [{ title: "Hello Ruby" }, { title: "Hello Hanami" }])
    end

    it "does't symbolize nested object that responds to to_hash" do
      nested = described_class.deep_symbolize("metadata" => WrappingHash.new("coverage" => 100))

      expect(nested[:metadata]).to be_kind_of(WrappingHash)
    end

    it "doesn't try to symbolize nested objects" do
      hash = described_class.deep_symbolize("foo" => ["bar"])

      expect(hash[:foo]).to eq(["bar"])
    end
  end

  describe ".deep_stringify" do
    it "returns ::Hash" do
      hash = described_class.deep_stringify("fub" => "baz")

      expect(hash).to be_kind_of(::Hash)
    end

    it "stringify keys" do
      hash = described_class.deep_stringify(fub: "baz")

      expect(hash["fub"]).to eq("baz")
      expect(hash.key?(:fub)).to be(false)
    end

    it "doesn't mutate original input" do
      input = { nested: { key: "value" } }
      described_class.deep_stringify(input)

      expect(input).to eq(nested: { key: "value" })
    end

    it "stringifies nested hashes" do
      hash = described_class.deep_stringify(nested: { key: "value" })

      expect(hash["nested"]).to be_kind_of(::Hash)
      expect(hash["nested"]["key"]).to eq("value")
    end

    it "stringifies deep nested hashes" do
      hash = described_class.deep_stringify(nested1: { nested2: { nested3: { key: 1 } } })

      expect(hash.keys).to eq(["nested1"])

      hash1 = hash["nested1"]
      expect(hash1).to be_kind_of(::Hash)
      expect(hash1.keys).to eq(["nested2"])

      hash2 = hash1["nested2"]
      expect(hash2).to be_kind_of(::Hash)
      expect(hash2.keys).to eq(["nested3"])

      hash3 = hash2["nested3"]
      expect(hash3).to be_kind_of(::Hash)
      expect(hash3.keys).to eq(["key"])

      expect(hash3["key"]).to eq(1)
    end

    it "stringifies arrays of hashes" do
      hash = described_class.deep_stringify(books: [{ title: "Hello Ruby" }, { title: "Hello Hanami" }])
      expect(hash).to eq("books" => [{ "title" => "Hello Ruby" }, { "title" => "Hello Hanami" }])
    end

    it "does't stringify nested object that responds to to_hash" do
      nested = described_class.deep_stringify(metadata: WrappingHash.new(coverage: 100))

      expect(nested["metadata"]).to be_kind_of(WrappingHash)
    end

    it "doesn't try to stringify nested objects" do
      hash = described_class.deep_stringify(foo: [:bar])

      expect(hash["foo"]).to eq([:bar])
    end
  end

  describe ".deep_dup" do
    it "returns ::Hash" do
      hash = described_class.deep_dup({})

      expect(hash).to be_kind_of(::Hash)
    end

    it "duplicates string values" do
      input  = { "a" => "hello" }
      result = described_class.deep_dup(input)

      result["a"] << " world"

      expect(input.fetch("a")).to eq("hello")
    end

    it "duplicates array values" do
      input  = { "a" => [1, 2, 3] }
      result = described_class.deep_dup(input)

      result["a"] << 4

      expect(input.fetch("a")).to eq([1, 2, 3])
    end

    it "duplicates hash values" do
      input  = { "a" => { "b" => 2 } }
      result = described_class.deep_dup(input)

      result["a"]["c"] = 3

      expect(input.fetch("a")).to eq("b" => 2)
    end

    it "duplicates nested hashes" do
      input  = { "a" => { "b" => { "c" => 3 } } }
      result = described_class.deep_dup(input)

      result["a"].delete("b")

      expect(input).to eq("a" => { "b" => { "c" => 3 } })
    end
  end

  describe ".deep_serialize" do
    let(:input) do
      klass = Class.new(OpenStruct) do
        def to_hash
          to_h
        end
      end

      klass.new("foo" => "bar", "baz" => [klass.new(hello: "world")])
    end

    it "returns a ::Hash" do
      expect(described_class.deep_serialize(input)).to be_kind_of(::Hash)
    end

    it "deeply serializes input" do
      expected = { foo: "bar", baz: [{ hello: "world" }] }
      actual = described_class.deep_serialize(input)

      expect(actual).to eq(expected)
    end

    it "uses symbols as keys" do
      output = described_class.deep_serialize(input)

      expect(output).to be_any
      output.each_key do |key|
        expect(key).to be_kind_of(::Symbol)
      end
    end
  end

  describe ".stringify" do
    it "returns ::Hash" do
      hash = described_class.stringify("fub" => "baz")

      expect(hash).to be_kind_of(::Hash)
    end

    it "stringify keys" do
      hash = described_class.stringify(fub: "baz")

      expect(hash).to eq("fub" => "baz")
    end

    it "doesn't mutate original input" do
      input = { "fub" => "baz" }
      described_class.stringify(input)

      expect(input).to eq("fub" => "baz")
    end

    it "doesn't stringify nested hashes" do
      hash = described_class.stringify("nested" => { key: "value" })
      expect(hash["nested"].keys).to eq([:key])
    end
  end
end
