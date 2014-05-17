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

  describe '#dasherize' do
    it 'substitutes underscores with dashes' do
      string = Lotus::Utils::String.new('lotus_utils')
      string.dasherize.must_equal 'lotus-utils'
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

  describe '#demodulize' do
    it 'returns the class name without the namespace' do
      Lotus::Utils::String.new('String').demodulize.must_equal('String')
      Lotus::Utils::String.new('Lotus::Utils::String').demodulize.must_equal('String')
    end
  end

  describe '#tokenize' do
    before do
      @logger = []
    end

    it 'calls the given block for each token occurrence' do
      string = Lotus::Utils::String.new('Lotus::(Utils|App)')
      string.tokenize do |token|
        @logger.push token
      end

      @logger.must_equal(['Lotus::Utils', 'Lotus::App'])
    end

    it "guarantees the block to be called even when the token conditions aren't met" do
      string = Lotus::Utils::String.new('Lotus')
      string.tokenize do |token|
        @logger.push token
      end

      @logger.must_equal(['Lotus'])
    end

    it 'returns nil' do
      result = Lotus::Utils::String.new('Lotus::(Utils|App)').tokenize { }
      result.must_be_nil
    end
  end
end
