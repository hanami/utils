# frozen_string_literal: true
require "hanami/utils/path_prefix"

RSpec.describe Hanami::Utils::PathPrefix do
  it "exposes itself as a string" do
    prefix = Hanami::Utils::PathPrefix.new
    expect(prefix).to eq("")
  end

  it "adds root prefix only when needed" do
    prefix = Hanami::Utils::PathPrefix.new("/fruits")
    expect(prefix).to eq("/fruits")
  end

  describe "#join" do
    it "returns a PathPrefix" do
      prefix = Hanami::Utils::PathPrefix.new("orders", "?").join("new")
      expect(prefix).to be_kind_of(Hanami::Utils::PathPrefix)
      expect(prefix.__send__(:separator)).to eq("?")
    end

    it "joins a string" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.join("peaches")).to eq "/fruits/peaches"
    end

    it "joins a prefixed string" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.join("/cherries")).to eq "/fruits/cherries"
    end

    it "joins a string that is the same as the prefix" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.join("fruits")).to eq "/fruits/fruits"
    end

    it "joins a string when the root is blank" do
      prefix = Hanami::Utils::PathPrefix.new
      expect(prefix.join("tea")).to eq "/tea"
    end

    it "joins a prefixed string when the root is blank" do
      prefix = Hanami::Utils::PathPrefix.new
      expect(prefix.join("/tea")).to eq "/tea"
    end

    it "joins multiple strings" do
      prefix = Hanami::Utils::PathPrefix.new
      expect(prefix.join("assets", "application.js")).to eq "/assets/application.js"

      prefix = Hanami::Utils::PathPrefix.new("myapp")
      expect(prefix.join("assets", "application.js")).to eq "/myapp/assets/application.js"

      prefix = Hanami::Utils::PathPrefix.new("/myapp")
      expect(prefix.join("/assets", "application.js")).to eq "/myapp/assets/application.js"
    end

    it "rejects entries that are matching separator" do
      prefix = Hanami::Utils::PathPrefix.new("/assets")
      expect(prefix.join("/")).to eq "/assets"
    end

    it "removes trailing occurrences of separator" do
      prefix = Hanami::Utils::PathPrefix.new("curcuma")
      expect(prefix.join(nil)).to eq "/curcuma"
    end
  end

  describe "#relative_join" do
    it "returns a PathPrefix" do
      prefix = Hanami::Utils::PathPrefix.new("orders", "&").relative_join("new")
      expect(prefix).to be_kind_of(Hanami::Utils::PathPrefix)
      expect(prefix.__send__(:separator)).to eq("&")
    end

    it "joins a string without prefixing with separator" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.relative_join("peaches")).to eq "fruits/peaches"
    end

    it "joins a prefixed string without prefixing with separator" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.relative_join("/cherries")).to eq "fruits/cherries"
    end

    it "joins a string when the root is blank without prefixing with separator" do
      prefix = Hanami::Utils::PathPrefix.new
      expect(prefix.relative_join("tea")).to eq "tea"
    end

    it "joins a prefixed string when the root is blank and removes the prefix" do
      prefix = Hanami::Utils::PathPrefix.new
      expect(prefix.relative_join("/tea")).to eq "tea"
    end

    it "joins a string with custom separator" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.relative_join("cherries", "_")).to eq "fruits_cherries"
    end

    it "joins a prefixed string without prefixing with custom separator" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect(prefix.relative_join("_cherries", "_")).to eq "fruits_cherries"
    end

    it "changes all the occurences of the current separator with the given one" do
      prefix = Hanami::Utils::PathPrefix.new("?fruits", "?")
      expect(prefix.relative_join("cherries", "_")).to eq "fruits_cherries"
    end

    it "removes trailing occurrences of separator" do
      prefix = Hanami::Utils::PathPrefix.new("jojoba")
      expect(prefix.relative_join(nil)).to eq "jojoba"
    end

    it "rejects entries that are matching separator" do
      prefix = Hanami::Utils::PathPrefix.new("assets")
      expect(prefix.relative_join("/")).to eq "assets"
    end

    it "raises error if the given separator is nil" do
      prefix = Hanami::Utils::PathPrefix.new("fruits")
      expect { prefix.relative_join("_cherries", nil) }.to raise_error(TypeError)
    end
  end

  describe "string interface" do
    describe "equality" do
      it "has a working equality" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        other  = Hanami::Utils::PathPrefix.new("hanami")

        expect(string).to eq(other)
      end

      it "has a working equality with raw strings" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        expect(string).to eq("hanami")
      end
    end

    describe "case equality" do
      it "has a working case equality" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        other  = Hanami::Utils::PathPrefix.new("hanami")
        expect(string === other).to be_truthy # rubocop:disable Style/CaseEquality
      end

      it "has a working case equality with raw strings" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        expect(string === "hanami").to be_truthy # rubocop:disable Style/CaseEquality
      end
    end

    describe "value equality" do
      it "has a working value equality" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        other  = Hanami::Utils::PathPrefix.new("hanami")
        expect(string).to eql(other)
      end

      it "has a working value equality with raw strings" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        expect(string).to eql("hanami")
      end
    end

    describe "identity equality" do
      it "has a working identity equality" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        expect(string).to equal(string)
      end

      it "has a working identity equality with raw strings" do
        string = Hanami::Utils::PathPrefix.new("hanami")
        expect(string).not_to equal("hanami")
      end
    end

    describe "#hash" do
      it "returns the same hash result of ::String" do
        expected = "hello".hash
        actual   = Hanami::Utils::PathPrefix.new("hello").hash

        expect(actual).to eq expected
      end
    end
  end
end
