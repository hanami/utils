require 'test_helper'
require 'lotus/utils/inflector'
require 'lotus/utils/string'

describe Lotus::Utils::Inflector do
  describe '.pluralize' do
    it "returns nil when nil is given" do
      actual = Lotus::Utils::Inflector.pluralize(nil)
      actual.must_be_nil
    end

    it "returns empty string when empty string is given" do
      actual = Lotus::Utils::Inflector.pluralize("")
      actual.must_be_empty
    end

    it "returns empty string when empty string is given (multiple chars)" do
      actual = Lotus::Utils::Inflector.pluralize(string = "   ")
      actual.must_equal string
    end

    TEST_PLURALS.each do |singular, plural|
      it %(pluralizes "#{ singular }" to "#{ plural }") do
        actual = Lotus::Utils::Inflector.pluralize(singular)
        actual.must_equal plural
      end

      it %(pluralizes titleized "#{ Lotus::Utils::String.new(singular).titleize }" to "#{ plural }") do
        actual = Lotus::Utils::Inflector.pluralize(Lotus::Utils::String.new(singular).titleize)
        actual.must_equal Lotus::Utils::String.new(plural).titleize
      end

      it %(doesn't pluralize "#{ plural }" as it's already plural) do
        actual = Lotus::Utils::Inflector.pluralize(plural)
        actual.must_equal plural
      end

      it %(doesn't pluralize titleized "#{ Lotus::Utils::String.new(singular).titleize }" as it's already plural) do
        actual = Lotus::Utils::Inflector.pluralize(Lotus::Utils::String.new(plural).titleize)
        actual.must_equal Lotus::Utils::String.new(plural).titleize
      end
    end
  end
end
