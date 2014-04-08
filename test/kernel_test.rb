require 'test_helper'
require 'lotus/utils/kernel'

describe Lotus::Utils::Kernel do
  describe '.Array' do
    before do
      @result = Lotus::Utils::Kernel.Array(input)
    end

    describe 'when nil is given' do
      let(:input) { nil }

      it 'returns an empty array' do
        @result.must_equal []
      end
    end

    describe 'when an object is given' do
      let(:input) { Object.new }

      it 'returns an array' do
        @result.must_equal [input]
      end
    end

    describe 'when an array is given' do
      let(:input) { [Object.new] }

      it 'returns an array' do
        @result.must_equal input
      end
    end

    describe 'when a nested array is given' do
      let(:input) { [1, [2, 3]] }

      it 'returns a flatten array' do
        @result.must_equal [1,2,3]
      end
    end

    describe 'when an array with nil values is given' do
      let(:input) { [1, [nil, 3]] }

      it 'returns a compacted array' do
        @result.must_equal [1,3]
      end
    end

    describe 'when an array with duplicated values is given' do
      let(:input) { [2, [2, 3]] }

      it 'returns an array with uniq values' do
        @result.must_equal [2,3]
      end
    end
  end
end
