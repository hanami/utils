require 'test_helper'
require 'bigdecimal'
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

  describe '.Integer' do
    describe 'successful operations' do
      before do
        PersonFavNumber = Struct.new(:name) do
          def to_int
            23
          end
        end

        @result = Lotus::Utils::Kernel.Integer(input)
      end

      after do
        Object.send(:remove_const, :PersonFavNumber)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns nil' do
          @result.must_equal nil
        end
      end

      describe 'when a fixnum given' do
        let(:input) { 1 }

        it 'returns an integer' do
          @result.must_equal 1
        end
      end

      describe 'when a float is given' do
        let(:input) { 1.2 }

        it 'returns an integer' do
          @result.must_equal 1
        end
      end

      describe 'when a string given' do
        let(:input) { '23' }

        it 'returns an integer' do
          @result.must_equal 23
        end
      end

      describe 'when a string representing a float number is given' do
        let(:input) { '23.4' }

        it 'returns an integer' do
          @result.must_equal 23
        end
      end

      describe 'when a bignum is given' do
        let(:input) { 13289301283 ** 2 }

        it 'returns an bignum' do
          @result.must_equal 176605528590345446089
        end
      end

      describe 'when a bigdecimal is given' do
        let(:input) { BigDecimal.new('12.0001') }

        it 'returns an bignum' do
          @result.must_equal 12
        end
      end

      describe 'when a complex number is given' do
        let(:input) { Complex(0.3) }

        it 'returns an integer' do
          @result.must_equal 0
        end
      end

      describe 'when a string representing a complex number is given' do
        let(:input) { '2.5/1' }

        it 'returns an integer' do
          @result.must_equal 2
        end
      end

      describe 'when a rational number is given' do
        let(:input) { Rational(0.3) }

        it 'returns an integer' do
          @result.must_equal 0
        end
      end

      describe 'when a string representing a rational number is given' do
        let(:input) { '2/3' }

        it 'returns an integer' do
          @result.must_equal 2
        end
      end

      describe 'when an object that implements #to_i is given' do
        let(:input) { Time.at(0) }

        it 'returns an integer' do
          @result.must_equal 0
        end
      end

      describe 'when an object that implements #to_int is given' do
        let(:input) { PersonFavNumber.new('Luca') }

        it 'returns an integer' do
          @result.must_equal 23
        end
      end
    end

    describe 'failure operations' do
      describe "when a an object that doesn't implement any integer interface" do
        let(:input) { OpenStruct.new(color: 'purple') }

        it 'raises error' do
          -> { Lotus::Utils::Kernel.Integer(input) }.must_raise(TypeError)
        end
      end

      describe 'when a bigdecimal infinity is given' do
        let(:input) { BigDecimal.new('Infinity') }

        it 'raises error' do
          -> { Lotus::Utils::Kernel.Integer(input) }.must_raise(FloatDomainError)
        end
      end

      describe 'when a bigdecimal NaN is given' do
        let(:input) { BigDecimal.new('NaN') }

        it 'raises error' do
          -> { Lotus::Utils::Kernel.Integer(input) }.must_raise(FloatDomainError)
        end
      end

      describe 'when a big complex number is given' do
        let(:input) { Complex(2,3) }

        it 'raises error' do
          -> { Lotus::Utils::Kernel.Integer(input) }.must_raise(RangeError)
        end
      end

      describe 'when a big rational number is given' do
        let(:input) { Rational(-8) ** Rational(1, 3) }

        it 'raises error' do
          -> { Lotus::Utils::Kernel.Integer(input) }.must_raise(RangeError)
        end
      end
    end
  end
end
