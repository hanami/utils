require 'test_helper'
require 'lotus/utils/options'

describe Lotus::Utils::Options do
  let(:options) { Lotus::Utils::Options.new(foo: :bar) }

  describe '#check_options!' do
    describe 'when options contain keys' do
      it 'does not raise exeption' do
        -> {
          options.check_options!(:foo)
        }.must_be_silent
      end
    end

    describe 'when options not contain a keys' do
      it 'raises exeption' do
        err = -> {
          options.check_options!(:baz, :foo)
        }.must_raise(ArgumentError)

        err.message.must_equal 'missing keyword: baz'
      end
    end
  end
end
