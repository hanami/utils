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

  # INSTANCE LEVEL INTERFACE

  describe "#initialize" do
    let(:input_to_hash) do
      Class.new do
        def to_hash
          Hash[foo: "bar"]
        end
      end.new
    end

    let(:input_to_h) do
      Class.new do
        def to_h
          Hash[head: "tail"]
        end
      end.new
    end

    it "holds values passed to the constructor", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("foo" => "bar")
      expect(hash["foo"]).to eq("bar")
    end

    it "assigns default via block", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new { |h, k| h[k] = [] }
      hash["foo"].push "bar"

      expect(hash).to eq("foo" => ["bar"])
    end

    it "accepts a Hanami::Utils::Hash", silence_deprecations: true do
      arg  = Hanami::Utils::Hash.new("foo" => "bar")
      hash = Hanami::Utils::Hash.new(arg)

      expect(hash.to_h).to be_kind_of(::Hash)
    end

    it "accepts object that implements #to_hash", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new(input_to_hash)

      expect(hash.to_h).to eq(input_to_hash.to_hash)
    end

    it "accepts frozen values", silence_deprecations: true do
      expect { Hanami::Utils::Hash.new({}.freeze) }
        .to_not raise_error
    end

    it "raises error when object doesn't implement #to_hash" do
      expect { Hanami::Utils::Hash.new(input_to_h) }
        .to raise_error(NoMethodError)
    end
  end

  describe "#symbolize!" do
    it "symbolize keys", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("fub" => "baz")
      hash.symbolize!

      expect(hash["fub"]).to be_nil
      expect(hash[:fub]).to eq("baz")
    end

    it "does not symbolize nested hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("nested" => { "key" => "value" })
      hash.symbolize!

      expect(hash[:nested].keys).to eq(["key"])
    end
  end

  describe "#deep_symbolize!" do
    it "symbolize keys", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("fub" => "baz")
      hash.deep_symbolize!

      expect(hash["fub"]).to be_nil
      expect(hash[:fub]).to eq("baz")
    end

    it "symbolizes nested hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("nested" => { "key" => "value" })
      hash.deep_symbolize!

      expect(hash[:nested]).to be_kind_of Hanami::Utils::Hash
      expect(hash[:nested][:key]).to eq("value")
    end

    it "symbolizes deep nested hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("nested1" => { "nested2" => { "nested3" => { "key" => 1 } } })
      hash.deep_symbolize!

      expect(hash.keys).to eq([:nested1])

      hash1 = hash[:nested1]
      expect(hash1.keys).to eq([:nested2])

      hash2 = hash1[:nested2]
      expect(hash2.keys).to eq([:nested3])

      hash3 = hash2[:nested3]
      expect(hash3.keys).to eq([:key])

      expect(hash3[:key]).to eq(1)
    end

    it "symbolize nested Hanami::Utils::Hashes", silence_deprecations: true do
      nested = Hanami::Utils::Hash.new("key" => "value")
      hash = Hanami::Utils::Hash.new("nested" => nested)
      hash.deep_symbolize!

      expect(hash[:nested]).to be_kind_of Hanami::Utils::Hash
      expect(hash[:nested][:key]).to eq("value")
    end

    it "symbolize nested object that responds to to_hash", silence_deprecations: true do
      nested = Hanami::Utils::Hash.new("metadata" => WrappingHash.new("coverage" => 100))
      nested.deep_symbolize!

      expect(nested[:metadata]).to be_kind_of Hanami::Utils::Hash
      expect(nested[:metadata][:coverage]).to eq(100)
    end

    it "doesn't try to symbolize nested objects", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("foo" => ["bar"])
      hash.deep_symbolize!

      expect(hash[:foo]).to eq(["bar"])
    end
  end

  describe "#stringify!" do
    it "covert keys to strings", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new(fub: "baz")
      hash.stringify!

      expect(hash[:fub]).to be_nil
      expect(hash["fub"]).to eq("baz")
    end

    it "stringifies nested hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new(nested: { key: "value" })
      hash.stringify!

      expect(hash["nested"]).to be_kind_of Hanami::Utils::Hash
      expect(hash["nested"]["key"]).to eq("value")
    end

    it "stringifies nested Hanami::Utils::Hashes", silence_deprecations: true do
      nested = Hanami::Utils::Hash.new(key: "value")
      hash = Hanami::Utils::Hash.new(nested: nested)
      hash.stringify!

      expect(hash["nested"]).to be_kind_of Hanami::Utils::Hash
      expect(hash["nested"]["key"]).to eq("value")
    end

    it "stringifies nested object that responds to to_hash", silence_deprecations: true do
      nested = Hanami::Utils::Hash.new(metadata: WrappingHash.new(coverage: 100))
      nested.stringify!

      expect(nested["metadata"]).to be_kind_of Hanami::Utils::Hash
      expect(nested["metadata"]["coverage"]).to eq(100)
    end
  end

  describe "#deep_dup" do
    it "returns an instance of Utils::Hash", silence_deprecations: true do
      duped = Hanami::Utils::Hash.new("foo" => "bar").deep_dup
      expect(duped).to be_kind_of(Hanami::Utils::Hash)
    end

    it "returns a hash with duplicated values", silence_deprecations: true do
      hash  = Hanami::Utils::Hash.new("foo" => "bar", "baz" => "x")
      duped = hash.deep_dup

      duped["foo"] = nil
      duped["baz"].upcase!

      expect(hash["foo"]).to eq("bar")
      expect(hash["baz"]).to eq("x")
    end

    it "doesn't try to duplicate value that can't perform this operation", silence_deprecations: true do
      original = {
        "nil"        => nil,
        "false"      => false,
        "true"       => true,
        "symbol"     => :symbol,
        "fixnum"     => 23,
        "bignum"     => 13_289_301_283**2,
        "float"      => 1.0,
        "complex"    => Complex(0.3),
        "bigdecimal" => BigDecimal("12.0001"),
        "rational"   => Rational(0.3)
      }

      hash  = Hanami::Utils::Hash.new(original)
      duped = hash.deep_dup

      expect(duped).to eq(original)
      expect(duped.object_id).not_to eq(original.object_id)
    end

    it "returns a hash with nested duplicated values", silence_deprecations: true do
      hash  = Hanami::Utils::Hash.new("foo" => { "bar" => "baz" }, "x" => Hanami::Utils::Hash.new("y" => "z"))
      duped = hash.deep_dup

      duped["foo"]["bar"].reverse!
      duped["x"]["y"].upcase!

      expect(hash["foo"]["bar"]).to eq("baz")
      expect(hash["x"]["y"]).to eq("z")
    end

    it "preserves original class", silence_deprecations: true do
      duped = Hanami::Utils::Hash.new("foo" => {}, "x" => Hanami::Utils::Hash.new).deep_dup

      expect(duped["foo"]).to be_kind_of(::Hash)
      expect(duped["x"]).to be_kind_of(Hanami::Utils::Hash)
    end
  end

  describe "hash interface" do
    it "returns a new Hanami::Utils::Hash for methods which return a ::Hash", silence_deprecations: true do
      hash   = Hanami::Utils::Hash.new("a" => 1)
      result = hash.clear

      expect(hash).to be_empty
      expect(result).to be_kind_of(Hanami::Utils::Hash)
    end

    it "returns a value that is compliant with ::Hash return value", silence_deprecations: true do
      hash   = Hanami::Utils::Hash.new("a" => 1)
      result = hash.assoc("a")

      expect(result).to eq ["a", 1]
    end

    it "responds to whatever ::Hash responds to" do
      hash = Hanami::Utils::Hash.new("a" => 1)

      expect(hash).to respond_to :rehash
      expect(hash).not_to respond_to :unknown_method
    end

    it "accepts blocks for methods", silence_deprecations: true do
      hash   = Hanami::Utils::Hash.new("a" => 1)
      result = hash.delete_if { |k, _| k == "a" }

      expect(result).to be_empty
    end

    describe "#to_h" do
      it "returns a ::Hash", silence_deprecations: true do
        actual = Hanami::Utils::Hash.new("a" => 1).to_h
        expect(actual).to eq("a" => 1)
      end

      it "returns nested ::Hash", silence_deprecations: true do
        hash = {
          tutorial: {
            instructions: [
              { title: "foo",  body: "bar" },
              { title: "hoge", body: "fuga" }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash)
        expect(utils_hash).not_to be_kind_of(::Hash)

        actual = utils_hash.to_h
        expect(actual).to eq(hash)

        expect(actual[:tutorial]).to be_kind_of(::Hash)
        expect(actual[:tutorial][:instructions]).to all(be_kind_of(::Hash))
      end

      it "returns nested ::Hash (when symbolized)", silence_deprecations: true do
        hash = {
          "tutorial" => {
            "instructions" => [
              { "title" => "foo",  "body" => "bar" },
              { "title" => "hoge", "body" => "fuga" }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash).deep_symbolize!
        expect(utils_hash).not_to be_kind_of(::Hash)

        actual = utils_hash.to_h
        expect(actual).to eq(hash)

        expect(actual[:tutorial]).to be_kind_of(::Hash)
        expect(actual[:tutorial][:instructions]).to all(be_kind_of(::Hash))
      end
    end

    it "prevents information escape", silence_deprecations: true do
      actual = Hanami::Utils::Hash.new("a" => 1)
      hash   = actual.to_h
      hash["b"] = 2

      expect(actual.to_h).to eq("a" => 1)
    end

    it "prevents information escape for nested hash"
    # it 'prevents information escape for nested hash' do
    #   actual  = Hanami::Utils::Hash.new({'a' => {'b' => 2}})
    #   hash    = actual.to_h
    #   subhash = hash['a']
    #   subhash.merge!('c' => 3)

    #   expect(actual.to_h).to eq({'a' => {'b' => 2}})
    # end

    it "serializes nested objects that respond to to_hash", silence_deprecations: true do
      nested = Hanami::Utils::Hash.new(metadata: WrappingHash.new(coverage: 100))
      expect(nested.to_h).to eq(metadata: { coverage: 100 })
    end
  end

  describe "#to_hash" do
    it "returns a ::Hash", silence_deprecations: true do
      actual = Hanami::Utils::Hash.new("a" => 1).to_hash
      expect(actual).to eq("a" => 1)
    end

    it "returns nested ::Hash", silence_deprecations: true do
      hash = {
        tutorial: {
          instructions: [
            { title: "foo",  body: "bar" },
            { title: "hoge", body: "fuga" }
          ]
        }
      }

      utils_hash = Hanami::Utils::Hash.new(hash)
      expect(utils_hash).not_to be_kind_of(::Hash)

      actual = utils_hash.to_h
      expect(actual).to eq(hash)

      expect(actual[:tutorial]).to be_kind_of(::Hash)
      expect(actual[:tutorial][:instructions]).to all(be_kind_of(::Hash))
    end

    it "returns nested ::Hash (when symbolized)", silence_deprecations: true do
      hash = {
        "tutorial" => {
          "instructions" => [
            { "title" => "foo",  "body" => "bar" },
            { "title" => "hoge", "body" => "fuga" }
          ]
        }
      }

      utils_hash = Hanami::Utils::Hash.new(hash).deep_symbolize!
      expect(utils_hash).not_to be_kind_of(::Hash)

      actual = utils_hash.to_h
      expect(actual).to eq(hash)

      expect(actual[:tutorial]).to be_kind_of(::Hash)
      expect(actual[:tutorial][:instructions]).to all(be_kind_of(::Hash))
    end

    it "prevents information escape", silence_deprecations: true do
      actual = Hanami::Utils::Hash.new("a" => 1)
      hash   = actual.to_hash
      hash["b"] = 2

      expect(actual.to_hash).to eq("a" => 1)
    end
  end

  describe "#to_a" do
    it "returns an ::Array", silence_deprecations: true do
      actual = Hanami::Utils::Hash.new("a" => 1).to_a
      expect(actual).to eq([["a", 1]])
    end

    it "prevents information escape", silence_deprecations: true do
      actual = Hanami::Utils::Hash.new("a" => 1)
      array  = actual.to_a
      array.push(["b", 2])

      expect(actual.to_a).to eq([["a", 1]])
    end
  end

  describe "equality" do
    it "has a working equality", silence_deprecations: true do
      hash  = Hanami::Utils::Hash.new("a" => 1)
      other = Hanami::Utils::Hash.new("a" => 1)

      expect(hash == other).to be_truthy
    end

    it "has a working equality with raw hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("a" => 1)
      expect(hash == { "a" => 1 }).to be_truthy
    end
  end

  describe "case equality" do
    it "has a working case equality", silence_deprecations: true do
      hash  = Hanami::Utils::Hash.new("a" => 1)
      other = Hanami::Utils::Hash.new("a" => 1)

      expect(hash === other).to be_truthy # rubocop:disable Style/CaseEquality
    end

    it "has a working case equality with raw hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("a" => 1)
      expect(hash === { "a" => 1 }).to be_truthy # rubocop:disable Style/CaseEquality
    end
  end

  describe "value equality" do
    it "has a working value equality", silence_deprecations: true do
      hash  = Hanami::Utils::Hash.new("a" => 1)
      other = Hanami::Utils::Hash.new("a" => 1)

      expect(hash).to eql(other)
    end

    it "has a working value equality with raw hashes", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("a" => 1)
      expect(hash).to eql("a" => 1)
    end
  end

  describe "identity equality" do
    it "has a working identity equality" do
      hash = Hanami::Utils::Hash.new("a" => 1)
      expect(hash).to equal(hash)
    end

    it "has a working identity equality with raw hashes" do
      hash = Hanami::Utils::Hash.new("a" => 1)
      expect(hash).not_to equal("a" => 1)
    end
  end

  describe "#hash" do
    it "returns the same hash result of ::Hash", silence_deprecations: true do
      expected = { "l" => 23 }.hash
      actual   = Hanami::Utils::Hash.new("l" => 23).hash

      expect(actual).to eq expected
    end
  end

  describe "#inspect", silence_deprecations: true do
    it "returns the same output of ::Hash" do
      expected = { "l" => 23, l: 23 }.inspect
      actual   = Hanami::Utils::Hash.new("l" => 23, l: 23).inspect

      expect(actual).to eq expected
    end
  end

  describe "unknown method" do
    it "raises error" do
      begin
        Hanami::Utils::Hash.new("l" => 23).party!
      rescue NoMethodError => e
        expect(e.message).to eq %(undefined method `party!' for {\"l\"=>23}:Hanami::Utils::Hash)
      end
    end

    # See: https://github.com/hanami/utils/issues/48
    it "returns the correct object when a NoMethodError is raised", silence_deprecations: true do
      hash = Hanami::Utils::Hash.new("a" => 1)

      if RUBY_VERSION >= "2.4" # rubocop:disable Style/ConditionalAssignment
        exception_message = "undefined method `foo' for 1:Integer"
      else
        exception_message = "undefined method `foo' for 1:Fixnum"
      end

      expect { hash.all? { |_, v| v.foo } }.to raise_error(NoMethodError, include(exception_message))
    end
  end
end
