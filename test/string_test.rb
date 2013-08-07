require 'test_helper'
require 'lotus/utils/string'

describe Lotus::Utils::String do
  describe '#classify' do
    it 'returns a classified string' do
      Lotus::Utils::String.new('lotus').classify.must_equal('Lotus')
      Lotus::Utils::String.new('lotus_router').classify.must_equal('LotusRouter')
    end

    it 'returns a classified string from symbol' do
      Lotus::Utils::String.new(:lotus).classify.must_equal('Lotus')
      Lotus::Utils::String.new(:lotus_router).classify.must_equal('LotusRouter')
    end
  end

  describe '#underscore' do
    it 'keep self untouched' do
      string = Lotus::Utils::String.new('Lotus')
      string.underscore
      string.must_equal 'Lotus'
    end

    it 'removes all the upcase characters' do
      string = Lotus::Utils::String.new('Lotus')
      string.underscore.must_equal 'lotus'
    end

    it 'transforms camel case class names' do
      string = Lotus::Utils::String.new('LotusView')
      string.underscore.must_equal 'lotus_view'
    end

    it 'substitutes double colons with path separators' do
      string = Lotus::Utils::String.new('Lotus::View')
      string.underscore.must_equal 'lotus/view'
    end
  end
end
