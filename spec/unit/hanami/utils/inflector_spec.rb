# frozen_string_literal: true

require "hanami/utils/inflector"
require "hanami/utils/string"

RSpec.describe Hanami::Utils::Inflector do
  describe ".inflections" do
    it "adds exception for singular rule" do
      actual = Hanami::Utils::Inflector.singularize("analyses") # see spec/support/fixtures.rb
      expect(actual).to eq "analysis"

      actual = Hanami::Utils::Inflector.singularize("algae") # see spec/support/fixtures.rb
      expect(actual).to eq "alga"
    end

    it "adds exception for plural rule" do
      actual = Hanami::Utils::Inflector.pluralize("analysis") # see spec/support/fixtures.rb
      expect(actual).to eq "analyses"

      actual = Hanami::Utils::Inflector.pluralize("alga") # see spec/support/fixtures.rb
      expect(actual).to eq "algae"
    end

    it "adds exception for uncountable rule" do
      actual = Hanami::Utils::Inflector.pluralize("music") # see spec/support/fixtures.rb
      expect(actual).to eq "music"

      actual = Hanami::Utils::Inflector.singularize("music") # see spec/support/fixtures.rb
      expect(actual).to eq "music"

      actual = Hanami::Utils::Inflector.pluralize("butter") # see spec/support/fixtures.rb
      expect(actual).to eq "butter"

      actual = Hanami::Utils::Inflector.singularize("butter") # see spec/support/fixtures.rb
      expect(actual).to eq "butter"
    end
  end

  describe ".pluralize" do
    it "returns nil when nil is given" do
      actual = Hanami::Utils::Inflector.pluralize(nil)
      expect(actual).to be_nil
    end

    it "returns empty string when empty string is given" do
      actual = Hanami::Utils::Inflector.pluralize("")
      expect(actual).to be_empty
    end

    it "returns empty string when empty string is given (multiple chars)" do
      actual = Hanami::Utils::Inflector.pluralize(string = "   ")
      expect(actual).to eq string
    end

    it "returns instance of String" do
      result = Hanami::Utils::Inflector.pluralize("Hanami")
      expect(result.class).to eq ::String
    end

    it "doesn't modify original string" do
      string = "application"
      result = Hanami::Utils::Inflector.pluralize(string)

      expect(result.object_id).not_to eq(string.object_id)
      expect(string).to eq("application")
    end

    TEST_PLURALS.each do |singular, plural|
      it %(pluralizes "#{singular}" to "#{plural}") do
        actual = Hanami::Utils::Inflector.pluralize(singular)
        expect(actual).to eq plural
      end

      it %(pluralizes titleized "#{Hanami::Utils::String.new(singular).titleize}" to "#{plural}") do
        actual = Hanami::Utils::Inflector.pluralize(Hanami::Utils::String.new(singular).titleize)
        expect(actual).to eq Hanami::Utils::String.new(plural).titleize
      end

      #     it %(doesn't pluralize "#{ plural }" as it's already plural) do
      #       actual = Hanami::Utils::Inflector.pluralize(plural)
      #       expect(actual).to eq plural
      #     end

      #     it %(doesn't pluralize titleized "#{ Hanami::Utils::String.new(singular).titleize }" as it's already plural) do
      #       actual = Hanami::Utils::Inflector.pluralize(Hanami::Utils::String.new(plural).titleize)
      #       expect(actual).to eq Hanami::Utils::String.new(plural).titleize
      #     end
    end
  end

  describe ".singularize" do
    it "returns nil when nil is given" do
      actual = Hanami::Utils::Inflector.singularize(nil)
      expect(actual).to be_nil
    end

    it "returns empty string when empty string is given" do
      actual = Hanami::Utils::Inflector.singularize("")
      expect(actual).to be_empty
    end

    it "returns empty string when empty string is given (multiple chars)" do
      actual = Hanami::Utils::Inflector.singularize(string = "   ")
      expect(actual).to eq string
    end

    it "returns instance of String" do
      result = Hanami::Utils::Inflector.singularize("application")
      expect(result.class).to eq ::String
    end

    it "doesn't modify original string" do
      string = "applications"
      result = Hanami::Utils::Inflector.singularize(string)

      expect(result.object_id).not_to eq(string.object_id)
      expect(string).to eq("applications")
    end

    TEST_SINGULARS.each do |singular, plural|
      it %(singularizes "#{plural}" to "#{singular}") do
        actual = Hanami::Utils::Inflector.singularize(plural)
        expect(actual).to eq singular
      end

      it %(singularizes titleized "#{Hanami::Utils::String.new(plural).titleize}" to "#{singular}") do
        actual = Hanami::Utils::Inflector.singularize(Hanami::Utils::String.new(plural).titleize)
        expect(actual).to eq Hanami::Utils::String.new(singular).titleize
      end

      # it %(doesn't singularizes "#{ singular }" as it's already singular) do
      #   actual = Hanami::Utils::Inflector.singularize(singular)
      #   expect(actual).to eq singular
      # end

      # it %(doesn't singularizes titleized "#{ Hanami::Utils::String.new(plural).titleize }" as it's already singular) do
      #   actual = Hanami::Utils::Inflector.singularize(Hanami::Utils::String.new(singular).titleize)
      #   expect(actual).to Hanami::Utils::String.new(singular).titleize
      # end
    end
  end
end
