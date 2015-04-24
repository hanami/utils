require 'test_helper'
require 'lotus/utils/inflector'

describe Lotus::Utils::Inflector do
  describe '.pluralize' do
    TEST_PLURALS.each do |singular, plural|
      it %(pluralizes "#{ singular }" to "#{ plural }") do
        actual = Lotus::Utils::Inflector.pluralize(singular)
        actual.must_equal plural
      end

      it %(doesn't pluralize "#{ plural }" as it's already plural) do
        actual = Lotus::Utils::Inflector.pluralize(plural)
        actual.must_equal plural
      end
    end
  end
end
