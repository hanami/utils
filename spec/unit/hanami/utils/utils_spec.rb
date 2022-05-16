# frozen_string_literal: true

RSpec.describe Hanami::Utils do
  describe ".jruby?" do
    it "introspects the current platform" do
      if RUBY_PLATFORM == "java"
        expect(Hanami::Utils.jruby?).to eq(true)
      else
        expect(Hanami::Utils.jruby?).to eq(false)
      end
    end
  end

  describe ".rubinius?" do
    it "introspects the current platform" do
      if RUBY_ENGINE == "rbx"
        expect(Hanami::Utils.rubinius?).to eq(true)
      else
        expect(Hanami::Utils.rubinius?).to eq(false)
      end
    end
  end

  describe ".env" do
    context "when HANAMI_ENV is not given" do
      it "returns :development" do
        expect(Hanami::Utils.env).to eq(:development)
      end
    end

    context "when HANAMI_ENV is given" do
      before do
        allow(ENV).to receive(:fetch).with("HANAMI_ENV", "development").and_return("production")
      end

      it "returns symbolized HANAMI_ENV" do
        expect(Hanami::Utils.env).to eq(:production)
      end
    end
  end

  describe ".env?" do
    it "returns true" do
      expect(Hanami::Utils.env?("development", "test")).to eq(true)
    end

    context "when given names does not match HANAMI_ENV" do
      it "returns false" do
        expect(Hanami::Utils.env?("production")).to eq(false)
      end
    end
  end
end
