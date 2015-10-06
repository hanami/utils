require 'test_helper'
require 'lotus/utils/inflector'
require 'lotus/utils/string'

describe Lotus::Utils::Inflector do
  describe '.inflections' do
    it 'adds exception for singular rule' do
      actual = Lotus::Utils::Inflector.singularize('analyses') # see test/fixtures.rb
      actual.must_equal 'analysis'

      actual = Lotus::Utils::Inflector.singularize('algae') # see test/fixtures.rb
      actual.must_equal 'alga'
    end

    it 'adds exception for plural rule' do
      actual = Lotus::Utils::Inflector.pluralize('analysis') # see test/fixtures.rb
      actual.must_equal 'analyses'

      actual = Lotus::Utils::Inflector.pluralize('alga') # see test/fixtures.rb
      actual.must_equal 'algae'
    end

    it 'adds exception for uncountable rule' do
      actual = Lotus::Utils::Inflector.pluralize('music') # see test/fixtures.rb
      actual.must_equal 'music'

      actual = Lotus::Utils::Inflector.singularize('music') # see test/fixtures.rb
      actual.must_equal 'music'

      actual = Lotus::Utils::Inflector.pluralize('butter') # see test/fixtures.rb
      actual.must_equal 'butter'

      actual = Lotus::Utils::Inflector.singularize('butter') # see test/fixtures.rb
      actual.must_equal 'butter'
    end
  end

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

    it "returns instance of String" do
      result = Lotus::Utils::Inflector.pluralize("Lotus")
      result.class.must_equal ::String
    end

    it "doesn't modify original string" do
      string = "application"
      result = Lotus::Utils::Inflector.pluralize(string)

      result.object_id.wont_equal(string.object_id)
      string.must_equal("application")
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

  #     it %(doesn't pluralize "#{ plural }" as it's already plural) do
  #       actual = Lotus::Utils::Inflector.pluralize(plural)
  #       actual.must_equal plural
  #     end

  #     it %(doesn't pluralize titleized "#{ Lotus::Utils::String.new(singular).titleize }" as it's already plural) do
  #       actual = Lotus::Utils::Inflector.pluralize(Lotus::Utils::String.new(plural).titleize)
  #       actual.must_equal Lotus::Utils::String.new(plural).titleize
  #     end
    end
  end

  describe '.singularize' do
    it "returns nil when nil is given" do
      actual = Lotus::Utils::Inflector.singularize(nil)
      actual.must_be_nil
    end

    it "returns empty string when empty string is given" do
      actual = Lotus::Utils::Inflector.singularize("")
      actual.must_be_empty
    end

    it "returns empty string when empty string is given (multiple chars)" do
      actual = Lotus::Utils::Inflector.singularize(string = "   ")
      actual.must_equal string
    end

    it "returns instance of String" do
      result = Lotus::Utils::Inflector.singularize("application")
      result.class.must_equal ::String
    end

    it "doesn't modify original string" do
      string = "applications"
      result = Lotus::Utils::Inflector.singularize(string)

      result.object_id.wont_equal(string.object_id)
      string.must_equal("applications")
    end

    TEST_SINGULARS.each do |singular, plural|
      it %(singularizes "#{ plural }" to "#{ singular }") do
        actual = Lotus::Utils::Inflector.singularize(plural)
        actual.must_equal singular
      end

      it %(singularizes titleized "#{ Lotus::Utils::String.new(plural).titleize }" to "#{ singular }") do
        actual = Lotus::Utils::Inflector.singularize(Lotus::Utils::String.new(plural).titleize)
        actual.must_equal Lotus::Utils::String.new(singular).titleize
      end

      # it %(doesn't singularizes "#{ singular }" as it's already singular) do
      #   actual = Lotus::Utils::Inflector.singularize(singular)
      #   actual.must_equal singular
      # end

      # it %(doesn't singularizes titleized "#{ Lotus::Utils::String.new(plural).titleize }" as it's already singular) do
      #   actual = Lotus::Utils::Inflector.singularize(Lotus::Utils::String.new(singular).titleize)
      #   actual.must_equal Lotus::Utils::String.new(singular).titleize
      # end
    end
  end
end
