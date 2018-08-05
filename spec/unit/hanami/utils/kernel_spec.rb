require 'ostruct'
require 'bigdecimal'
require 'securerandom'
require 'hanami/utils/kernel'

RSpec.describe Hanami::Utils::Kernel do
  describe '.Array' do
    describe 'successful operations' do
      before do
        ResultSet = Struct.new(:records) do
          def to_a
            records.to_a.sort
          end
        end

        Response = Struct.new(:status, :headers, :body) do
          def to_ary
            [status, headers, body]
          end
        end

        @result = Hanami::Utils::Kernel.Array(input)
      end

      after do
        Object.send(:remove_const, :ResultSet)
        Object.send(:remove_const, :Response)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns an empty array' do
          expect(@result).to eq []
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'returns an empty array' do
          expect(@result).to eq [true]
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'returns an empty array' do
          expect(@result).to eq [false]
        end
      end

      describe 'when an object is given' do
        let(:input) { Object.new }

        it 'returns an array' do
          expect(@result).to eq [input]
        end
      end

      describe 'when an array is given' do
        let(:input) { [Object.new] }

        it 'returns an array' do
          expect(@result).to eq input
        end
      end

      describe 'when a nested array is given' do
        let(:input) { [1, [2, 3]] }

        it 'returns a flatten array' do
          expect(@result).to eq [1, 2, 3]
        end

        it "doesn't change the argument" do
          expect(input).to eq [1, [2, 3]]
        end
      end

      describe 'when an array with nil values is given' do
        let(:input) { [1, [nil, 3]] }

        it 'returns a compacted array' do
          expect(@result).to eq [1, 3]
        end
      end

      describe 'when an array with duplicated values is given' do
        let(:input) { [2, [2, 3]] }

        it 'returns an array with uniq values' do
          expect(@result).to eq [2, 3]
        end

        it "doesn't change the argument" do
          expect(input).to eq [2, [2, 3]]
        end
      end

      describe 'when a set is given' do
        let(:input) { Set.new([33, 12]) }

        it 'returns an array with uniq values' do
          expect(@result).to eq [33, 12]
        end
      end

      describe 'when a object that implements #to_a is given' do
        let(:input) { ResultSet.new([2, 1, 3]) }

        it 'returns an array' do
          expect(@result).to eq [1, 2, 3]
        end
      end

      describe 'when a object that implements #to_ary is given' do
        let(:input) { Response.new(200, {}, 'hello') }

        it 'returns an array' do
          expect(@result).to eq [200, {}, 'hello']
        end
      end
    end
  end

  describe '.Set' do
    before do
      UuidSet = Class.new do
        def initialize(*uuids)
          @uuids = uuids
        end

        def to_set
          Set.new.tap do |set|
            @uuids.each { |uuid| set.add(uuid) }
          end
        end
      end

      BaseObject = Class.new(BasicObject) do
        def nil?
          false
        end
      end
    end

    after do
      Object.send(:remove_const, :UuidSet)
      Object.send(:remove_const, :BaseObject)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.Set(input)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns an empty set' do
          expect(@result).to eq Set.new
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'returns a set' do
          expect(@result).to eq Set.new([true])
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'returns a set' do
          expect(@result).to eq Set.new([false])
        end
      end

      describe 'when an object is given' do
        let(:input) { Object.new }

        it 'returns an set' do
          expect(@result).to eq Set.new([input])
        end
      end

      describe 'when an array is given' do
        let(:input) { [1] }

        it 'returns an set' do
          expect(@result).to eq Set.new(input)
        end
      end

      describe 'when an hash is given' do
        let(:input) { Hash[a: 1] }

        it 'returns an set' do
          expect(@result).to eq Set.new([[:a, 1]])
        end
      end

      describe 'when a set is given' do
        let(:input) { Set.new([Object.new]) }

        it 'returns self' do
          expect(@result).to eq input
        end
      end

      describe 'when a nested array is given' do
        let(:input) { [1, [2, 3]] }

        it 'returns it wraps in a set' do
          expect(@result).to eq Set.new([1, [2, 3]])
        end
      end

      describe 'when an array with nil values is given' do
        let(:input) { [1, [nil, 3]] }

        it 'returns it wraps in a set' do
          expect(@result).to eq Set.new([1, [nil, 3]])
        end
      end

      describe 'when an set with duplicated values is given' do
        let(:input) { [2, 3, 3] }

        it 'returns an set with uniq values' do
          expect(@result).to eq Set.new([2, 3])
        end
      end

      describe 'when an set with nested duplicated values is given' do
        let(:input) { [2, [2, 3]] }

        it 'returns it wraps in a set' do
          expect(@result).to eq Set.new([2, [2, 3]])
        end
      end

      describe 'when a object that implements #to_set is given' do
        let(:input) { UuidSet.new(*args) }
        let(:args)  { [SecureRandom.uuid, SecureRandom.uuid] }

        it 'returns an set' do
          expect(@result).to eq Set.new(args)
        end
      end
    end

    describe 'failure operations' do
      describe "when a an object that doesn't implement #respond_to?" do
        let(:input) { BaseObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Set(input) }.to raise_error(TypeError)
        end

        it 'returns informations about the failure' do
          begin
            Hanami::Utils::Kernel.Set(input)
          rescue => e
            expect(e.message).to match "can't convert into Set"
          end
        end
      end
    end
  end

  describe '.Hash' do
    before do
      Room = Class.new do
        def initialize(*args)
          @args = args
        end

        def to_h
          Hash[*@args]
        end
      end

      Record = Class.new do
        def initialize(attributes = {})
          @attributes = attributes
        end

        def to_hash
          @attributes
        end
      end

      BaseObject = Class.new(BasicObject) do
        def nil?
          false
        end
      end
    end

    after do
      Object.send(:remove_const, :Room)
      Object.send(:remove_const, :Record)
      Object.send(:remove_const, :BaseObject)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.Hash(input)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns an empty hash' do
          expect(@result).to eq({})
        end
      end

      describe 'when an hash is given' do
        let(:input) { Hash[l: 23] }

        it 'returns the input' do
          expect(@result).to eq input
        end
      end

      describe 'when an array is given' do
        let(:input) { [[:a, 1]] }

        it 'returns an hash' do
          expect(@result).to eq Hash[a: 1]
        end
      end

      describe 'when a set is given' do
        let(:input) { Set.new([['x', 12]]) }

        it 'returns an hash' do
          expect(@result).to eq Hash['x' => 12]
        end
      end

      describe 'when a object that implements #to_h is given' do
        let(:input) { Room.new(:key, 123_456) }

        it 'returns an hash' do
          expect(@result).to eq Hash[key: 123_456]
        end
      end

      describe 'when a object that implements #to_hash is given' do
        let(:input) { Record.new(name: 'L') }

        it 'returns an hash' do
          expect(@result).to eq Hash[name: 'L']
        end
      end
    end

    describe 'failure operations' do
      describe "when a an object that doesn't implement #respond_to?" do
        let(:input) { BaseObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Hash(input)
          rescue => e
            expect(e.message).to eq "can't convert into Hash"
          end
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
      end

      describe 'when an array with one element is given' do
        let(:input) { [1] }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
      end

      describe 'when an array with two elements is given' do
        let(:input) { [:a, 1] }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a set of one element is given' do
        let(:input) { Set.new([1]) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a set of two elements is given' do
        let(:input) { Set.new([:a, 1]) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Hash(input) }.to raise_error(TypeError)
        end
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

        @result = Hanami::Utils::Kernel.Integer(input)
      end

      after do
        Object.send(:remove_const, :PersonFavNumber)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns 0' do
          expect(@result).to eq 0
        end
      end

      describe 'when a fixnum given' do
        let(:input) { 1 }

        it 'returns an integer' do
          expect(@result).to eq 1
        end
      end

      describe 'when a float is given' do
        let(:input) { 1.2 }

        it 'returns an integer' do
          expect(@result).to eq 1
        end
      end

      describe 'when a string given' do
        let(:input) { '23' }

        it 'returns an integer' do
          expect(@result).to eq 23
        end
      end

      describe 'when a string representing a float number is given' do
        let(:input) { '23.4' }

        it 'returns an integer' do
          expect(@result).to eq 23
        end
      end

      describe 'when an octal is given' do
        let(:input) { 0o11 }

        it 'returns the string representation' do
          expect(@result).to eq 9
        end
      end

      describe 'when a hex is given' do
        let(:input) { 0xf5 }

        it 'returns the string representation' do
          expect(@result).to eq 245
        end
      end

      describe 'when a bignum is given' do
        let(:input) { 13_289_301_283**2 }

        it 'returns an bignum' do
          expect(@result).to eq 176_605_528_590_345_446_089
        end
      end

      describe 'when a bigdecimal is given' do
        let(:input) { BigDecimal('12.0001') }

        it 'returns an bignum' do
          expect(@result).to eq 12
        end
      end

      describe 'when a complex number is given' do
        let(:input) { Complex(0.3) }

        it 'returns an integer' do
          expect(@result).to eq 0
        end
      end

      describe 'when a string representing a complex number is given' do
        let(:input) { '2.5/1' }

        it 'returns an integer' do
          expect(@result).to eq 2
        end
      end

      describe 'when a rational number is given' do
        let(:input) { Rational(0.3) }

        it 'returns an integer' do
          expect(@result).to eq 0
        end
      end

      describe 'when a string representing a rational number is given' do
        let(:input) { '2/3' }

        it 'returns an integer' do
          expect(@result).to eq 2
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.at(0).utc }

        it 'returns the string representation' do
          expect(@result).to eq 0
        end
      end

      describe 'when an object that implements #to_int is given' do
        let(:input) { PersonFavNumber.new('Luca') }

        it 'returns an integer' do
          expect(@result).to eq 23
        end
      end
    end

    describe 'failure operations' do
      describe 'true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end
      end

      describe 'false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end
      end

      describe "when a an object that doesn't implement #respond_to? " do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Integer(input)
          rescue => e
            expect(e.message).to eq "can't convert into Integer"
          end
        end
      end

      describe "when a an object that doesn't implement any integer interface" do
        let(:input) { OpenStruct.new(color: 'purple') }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Integer(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Integer"
          end
        end
      end

      describe 'when a bigdecimal infinity is given' do
        let(:input) { BigDecimal('Infinity') }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a bigdecimal NaN is given' do
        let(:input) { BigDecimal('NaN') }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Integer(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Integer"
          end
        end
      end

      describe 'when a big complex number is given' do
        let(:input) { Complex(2, 3) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Integer(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Integer"
          end
        end
      end

      describe 'when a big rational number is given' do
        let(:input) { Rational(-8)**Rational(1, 3) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Integer(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Integer"
          end
        end
      end

      describe 'when a string without numbers is given' do
        let(:input) { 'home' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }
            .to raise_error(TypeError, "can't convert #{input.inspect} into Integer")
        end
      end

      describe 'when a string which starts with an integer is given' do
        let(:input) { '23 street' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Integer(input) }
            .to raise_error(TypeError, "can't convert #{input.inspect} into Integer")
        end
      end
    end
  end

  describe '.BigDecimal' do
    describe 'successful operations' do
      before do
        PersonFavDecimalNumber = Struct.new(:name) do
          def to_d
            BigDecimal(Rational(23).to_s)
          end
        end

        @result = Hanami::Utils::Kernel.BigDecimal(input)
      end

      after do
        Object.send(:remove_const, :PersonFavDecimalNumber)
      end

      describe 'when a fixnum given' do
        let(:input) { 1 }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(1)
        end
      end

      describe 'when a float is given' do
        let(:input) { 1.2 }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('1.2')
        end
      end

      describe 'when a string given' do
        let(:input) { '23' }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(23)
        end
      end

      describe 'when a string representing a float number is given' do
        let(:input) { '23.1' }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('23.1')
        end
      end

      describe 'when an octal is given' do
        let(:input) { 0o11 }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(9)
        end
      end

      describe 'when a hex is given' do
        let(:input) { 0xf5 }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(245)
        end
      end

      describe 'when a bignum is given' do
        let(:input) { 13_289_301_283**2 }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(176_605_528_590_345_446_089)
        end
      end

      describe 'when a bigdecimal is given' do
        let(:input) { BigDecimal('12.0001') }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('12.0001')
        end
      end

      describe 'when a complex number with imaginary part is given' do
        let(:input) { Complex(758.3, 0) }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('758.3')
        end
      end

      describe 'when a complex number without imaginary part is given' do
        let(:input) { Complex(0.3) }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('0.3')
        end
      end

      describe 'when a string representing a complex number is given' do
        let(:input) { '2.5/1' }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('2.5')
        end
      end

      describe 'when a rational number is given' do
        let(:input) { Rational(0.3) }

        it 'returns an BigDecimal' do
          expect(@result).to eq BigDecimal(input.to_s)
        end
      end

      describe 'when a string representing a rational number is given' do
        let(:input) { '2/3' }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal('2/3')
        end
      end

      describe 'when a BigDecimal NaN is given' do
        let(:input) { 'NaN' }

        it 'returns a BigDecimal NaN' do
          expect(@result).to be_kind_of BigDecimal
          expect(@result).to be_nan
        end
      end

      describe 'when a BigDecimal Infinity (string) is given' do
        let(:input) { 'Infinity' }

        it 'returns a BigDecimal Infinity' do
          expect(@result).to be_kind_of BigDecimal
          expect(@result).to be_infinite
        end
      end

      describe 'when a BigDecimal Infinity is given' do
        let(:input) { BigDecimal('Infinity') }

        it 'returns the BigDecimal Infinity representation' do
          expect(@result).to eq BigDecimal('Infinity')
        end
      end

      describe 'when an object that implements #to_d is given' do
        let(:input) { PersonFavDecimalNumber.new('Luca') }

        it 'returns a BigDecimal' do
          expect(@result).to eq BigDecimal(23)
        end
      end
    end

    describe 'when a string which starts with a big decimal is given' do
      let(:input) { '23.0 street' }

      it 'returns an BigDecimal' do
        expect(Hanami::Utils::Kernel.BigDecimal(input)).to eq BigDecimal(23)
      end
    end

    # Bug: https://github.com/hanami/utils/issues/140
    describe 'when a negative bigdecimal is given' do
      let(:input) { BigDecimal('-12.0001') }

      it 'returns a BigDecimal' do
        expect(Hanami::Utils::Kernel.BigDecimal(input)).to eq BigDecimal('-12.0001')
      end
    end

    # Bug: https://github.com/hanami/utils/issues/140
    describe 'when the big decimal is less than 1 with high precision' do
      let(:input) { BigDecimal('0.0001') }

      it 'returns a BigDecimal' do
        expect(Hanami::Utils::Kernel.BigDecimal(input)).to eq BigDecimal('0.0001')
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end
      end

      describe "when a an object that doesn't implement #respond_to? " do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.BigDecimal(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.BigDecimal(input)
          rescue => e
            expect(e.message).to eq "can't convert into BigDecimal"
          end
        end
      end
    end
  end

  describe '.Float' do
    describe 'successful operations' do
      before do
        class Pi
          def to_f
            3.14
          end
        end

        @result = Hanami::Utils::Kernel.Float(input)
      end

      after do
        Object.send(:remove_const, :Pi)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns 0.0' do
          expect(@result).to eq 0.0
        end
      end

      describe 'when a float is given' do
        let(:input) { 1.2 }

        it 'returns the argument' do
          expect(@result).to eq 1.2
        end
      end

      describe 'when a fixnum given' do
        let(:input) { 1 }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 1.0
        end
      end

      describe 'when a string given' do
        let(:input) { '23' }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 23.0
        end
      end

      describe 'when a string representing a float number is given' do
        let(:input) { '23.4' }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 23.4
        end
      end

      describe 'when an octal is given' do
        let(:input) { 0o11 }

        it 'returns the base 10 float' do
          expect(@result).to eq 9.0
        end
      end

      describe 'when a hex is given' do
        let(:input) { 0xf5 }

        it 'returns the base 10 float' do
          expect(@result).to eq 245.0
        end
      end

      describe 'when a bignum is given' do
        let(:input) { 13_289_301_283**2 }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 176_605_528_590_345_446_089.0
        end
      end

      describe 'when a bigdecimal is given' do
        let(:input) { BigDecimal('12.0001') }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 12.0001
        end
      end

      describe 'when a bigdecimal infinity is given' do
        let(:input) { BigDecimal('Infinity') }

        it 'returns Infinity' do
          expect(@result).to be_kind_of(Float)
          expect(@result.to_s).to eq 'Infinity'
        end
      end

      describe 'when a bigdecimal NaN is given' do
        let(:input) { BigDecimal('NaN') }

        it 'returns NaN' do
          expect(@result).to be_kind_of(Float)
          expect(@result.to_s).to eq 'NaN'
        end
      end

      describe 'when a complex number is given' do
        let(:input) { Complex(0.3) }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 0.3
        end
      end

      describe 'when a string representing a complex number is given' do
        let(:input) { '2.5/1' }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 2.5
        end
      end

      describe 'when a rational number is given' do
        let(:input) { Rational(0.3) }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 0.3
        end
      end

      describe 'when a string representing a rational number is given' do
        let(:input) { '2/3' }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 2.0
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.at(0).utc }

        it 'returns the float representation' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 0.0
        end
      end

      describe 'when an object that implements #to_int is given' do
        let(:input) { Pi.new }

        it 'returns a float' do
          expect(@result).to be_kind_of(Float)
          expect(@result).to eq 3.14
        end
      end
    end

    describe 'failure operations' do
      describe 'true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end
      end

      describe 'false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a string without numbers is given' do
        let(:input) { 'home' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }
            .to raise_error(TypeError, "can't convert #{input.inspect} into Float")
        end
      end

      describe 'when a string which starts with a float is given' do
        let(:input) { '23.0 street' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }
            .to raise_error(TypeError, "can't convert #{input.inspect} into Float")
        end
      end

      describe "when a an object that doesn't implement #respond_to? " do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Float(input)
          rescue => e
            expect(e.message).to eq "can't convert into Float"
          end
        end
      end

      describe "when a an object that doesn't implement any float interface" do
        let(:input) { OpenStruct.new(color: 'purple') }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end
      end

      describe 'when a big complex number is given' do
        let(:input) { Complex(2, 3) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Float(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Float"
          end
        end
      end

      describe 'when a big rational number is given' do
        let(:input) { Rational(-8)**Rational(1, 3) }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Float(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Float(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Float"
          end
        end
      end
    end
  end

  describe '.String' do
    before do
      Book = Struct.new(:title)

      SimpleObject = Class.new(BasicObject) do
        def respond_to?(method_name, _include_private = false)
          method_name.to_sym == :to_s
        end

        def to_s
          'simple object'
        end
      end

      Isbn = Struct.new(:code) do
        def to_str
          code.to_s
        end
      end
    end

    after do
      Object.send(:remove_const, :Book)
      Object.send(:remove_const, :SimpleObject)
      Object.send(:remove_const, :Isbn)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.String(input)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns empty string' do
          expect(@result).to eq ''
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'returns nil' do
          expect(@result).to eq 'true'
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'returns nil' do
          expect(@result).to eq 'false'
        end
      end

      describe 'when an empty string is given' do
        let(:input) { '' }

        it 'returns it' do
          expect(@result).to eq ''
        end
      end

      describe 'when a string is given' do
        let(:input) { 'ciao' }

        it 'returns it' do
          expect(@result).to eq 'ciao'
        end
      end

      describe 'when an integer is given' do
        let(:input) { 23 }

        it 'returns the string representation' do
          expect(@result).to eq '23'
        end
      end

      describe 'when a float is given' do
        let(:input) { 3.14 }

        it 'returns the string representation' do
          expect(@result).to eq '3.14'
        end
      end

      describe 'when an octal is given' do
        let(:input) { 0o13 }

        it 'returns the string representation' do
          expect(@result).to eq '11'
        end
      end

      describe 'when a hex is given' do
        let(:input) { 0xc0ff33 }

        it 'returns the string representation' do
          expect(@result).to eq '12648243'
        end
      end

      describe 'when a big decimal is given' do
        let(:input) { BigDecimal(7944.2343, 10) }

        if RUBY_VERSION >= '2.4'
          it 'returns the string representation' do
            expect(@result).to eq '0.79442343e4'
          end
        else
          it 'returns the string representation' do
            expect(@result).to eq '0.79442343E4'
          end
        end
      end

      describe 'when a big decimal infinity is given' do
        let(:input) { BigDecimal('Infinity') }

        it 'returns the string representation' do
          expect(@result).to eq 'Infinity'
        end
      end

      describe 'when a big decimal NaN is given' do
        let(:input) { BigDecimal('NaN') }

        it 'returns the string representation' do
          expect(@result).to eq 'NaN'
        end
      end

      describe 'when a complex is given' do
        let(:input) { Complex(11, 2) }

        it 'returns the string representation' do
          expect(@result).to eq '11+2i'
        end
      end

      describe 'when a rational is given' do
        let(:input) { Rational(-22) }

        it 'returns the string representation' do
          expect(@result).to eq '-22/1'
        end
      end

      describe 'when an empty array is given' do
        let(:input) { [] }

        it 'returns the string representation' do
          expect(@result).to eq '[]'
        end
      end

      describe 'when an array of integers is given' do
        let(:input) { [1, 2, 3] }

        it 'returns the string representation' do
          expect(@result).to eq '[1, 2, 3]'
        end
      end

      describe 'when an array of strings is given' do
        let(:input) { %w[a b c] }

        it 'returns the string representation' do
          expect(@result).to eq '["a", "b", "c"]'
        end
      end

      describe 'when an array of objects is given' do
        let(:input) { [Object.new] }

        it 'returns the string representation' do
          expect(@result).to include '[#<Object:'
        end
      end

      describe 'when an empty hash is given' do
        let(:input) { {} }

        it 'returns the string representation' do
          expect(@result).to eq '{}'
        end
      end

      describe 'when an hash is given' do
        let(:input) { { a: 1, 'b' => 2 } }

        it 'returns the string representation' do
          expect(@result).to eq '{:a=>1, "b"=>2}'
        end
      end

      describe 'when a symbol is given' do
        let(:input) { :hanami }

        it 'returns the string representation' do
          expect(@result).to eq 'hanami'
        end
      end

      describe 'when an struct is given' do
        let(:input) { Book.new('DDD') }

        it 'returns the string representation' do
          expect(@result).to eq '#<struct Book title="DDD">'
        end
      end

      describe 'when an open struct is given' do
        let(:input) { OpenStruct.new(title: 'DDD') }

        it 'returns the string representation' do
          expect(@result).to eq '#<OpenStruct title="DDD">'
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.parse('2014-04-11') }

        it 'returns the string representation' do
          expect(@result).to eq '2014-04-11'
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.parse('2014-04-11 09:45') }

        it 'returns the string representation' do
          expect(@result).to eq '2014-04-11T09:45:00+00:00'
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.at(0).utc }

        it 'returns the string representation' do
          expect(@result).to eq '1970-01-01 00:00:00 UTC'
        end
      end

      describe 'when a class is given' do
        if RUBY_VERSION >= '2.4'
          let(:input) { Integer }
          it 'returns the string representation' do
            expect(@result).to eq 'Integer'
          end
        else
          let(:input) { Fixnum } # rubocop:disable Lint/UnifiedInteger
          it 'returns the string representation' do
            expect(@result).to eq 'Fixnum'
          end
        end
      end

      describe 'when a module is given' do
        let(:input) { Hanami }

        it 'returns the string representation' do
          expect(@result).to eq 'Hanami'
        end
      end

      describe 'when an object implements #to_s' do
        let(:input) { SimpleObject.new }

        it 'returns the string representation' do
          expect(@result).to eq 'simple object'
        end
      end

      describe 'when an object implements #to_str' do
        let(:input) { Isbn.new(123) }

        it 'returns the string representation' do
          expect(@result).to eq '123'
        end
      end
    end

    describe 'failure operations' do
      describe "when a an object that doesn't implement a string interface" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.String(input) }.to raise_error(TypeError)
        end
      end
    end
  end

  describe '.Boolean' do
    before do
      Answer = Struct.new(:answer) do
        def to_bool
          case answer
          when 'yes' then true
          else false
          end
        end
      end
    end

    after do
      Object.send(:remove_const, :Answer)
    end

    it 'defines Boolean' do
      expect(defined?(::Boolean)).to be_truthy, 'expected class Boolean'
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.Boolean(input)
      end

      describe 'when nil is given' do
        let(:input) { nil }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'returns true' do
          expect(@result).to eq true
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when 0 is given' do
        let(:input) { 0 }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when 1 is given' do
        let(:input) { 1 }

        it 'returns true' do
          expect(@result).to eq true
        end
      end

      describe 'when 2 is given' do
        let(:input) { 2 }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when -1 is given' do
        let(:input) { -1 }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when "0" is given (String)' do
        let(:input) { '0' }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when "1" is given (String)' do
        let(:input) { '1' }

        it 'returns true' do
          expect(@result).to eq true
        end
      end

      describe 'when "foo" is given (String)' do
        let(:input) { 'foo' }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when an object is given' do
        let(:input) { Object.new }

        it 'returns true' do
          expect(@result).to eq true
        end
      end

      describe 'when the given object responds to #to_bool' do
        let(:input) { Answer.new('no') }

        it 'returns the result of the serialization' do
          expect(@result).to eq false
        end
      end
    end

    describe 'failure operations' do
      describe "when a an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Boolean(input) }.to raise_error(TypeError)
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Boolean(input)
          rescue => e
            expect(e.message).to eq "can't convert into Boolean"
          end
        end
      end
    end
  end

  describe '.Date' do
    before do
      class Christmas
        def to_date
          Date.parse('Dec, 25')
        end
      end

      BaseObject = Class.new(BasicObject) do
        def respond_to?(_method_name)
          false
        end
      end
    end

    after do
      Object.send(:remove_const, :Christmas)
      Object.send(:remove_const, :BaseObject)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.Date(input)
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'returns the input' do
          expect(@result).to eq input
        end
      end

      describe 'when a string that represents a date is given' do
        let(:input) { '2014-04-17' }

        it 'returns a date' do
          expect(@result).to eq Date.parse(input)
        end
      end

      describe 'when a string that represents a timestamp is given' do
        let(:input) { '2014-04-17 18:50:01' }

        it 'returns a date' do
          expect(@result).to eq Date.parse('2014-04-17')
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'returns a date' do
          expect(@result).to eq Date.today
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'returns a date' do
          expect(@result).to eq Date.today
        end
      end

      describe 'when an object that implements #to_date is given' do
        let(:input) { Christmas.new }

        it 'returns a date' do
          expect(@result).to eq Date.parse('Dec, 25')
        end
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe 'when a fixnum is given' do
        let(:input) { 2 }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe 'when a float is given' do
        let(:input) { 2332.903007 }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe "when a string that doesn't represent a date is given" do
        let(:input) { 'lego' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe 'when a string that represent a hour is given' do
        let(:input) { '18:55' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Date"
          end
        end
      end

      describe "when an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert into Date"
          end
        end
      end

      describe "when an object that doesn't implement #to_s?" do
        let(:input) { BaseObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Date(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Date(input)
          rescue => e
            expect(e.message).to eq "can't convert into Date"
          end
        end
      end
    end
  end

  describe '.DateTime' do
    before do
      class NewYearEve
        def to_datetime
          DateTime.parse('Jan, 1')
        end
      end

      BaseObject = Class.new(BasicObject) do
        def respond_to?(_method_name)
          false
        end
      end
    end

    after do
      Object.send(:remove_const, :NewYearEve)
      Object.send(:remove_const, :BaseObject)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.DateTime(input)
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'returns the input' do
          expect(@result).to eq input
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'returns a datetime' do
          expect(@result).to eq DateTime.parse(Date.today.to_s)
        end
      end

      describe 'when a string that represents a date is given' do
        let(:input) { '2014-04-17' }

        it 'returns a datetime' do
          expect(@result).to eq DateTime.parse(input)
        end
      end

      describe 'when a string that represents a timestamp is given' do
        let(:input) { '2014-04-17 22:51:48' }

        it 'returns a datetime' do
          expect(@result).to eq DateTime.parse(input)
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'returns a datetime' do
          expect(@result).to eq input.to_datetime
        end
      end

      describe 'when an object that implements #to_datetime is given' do
        let(:input) { NewYearEve.new }

        it 'returns a datetime' do
          expect(@result).to eq DateTime.parse('Jan 1')
        end
      end

      describe 'when a string that represent a hour is given' do
        let(:input) { '23:12' }

        it 'returns a datetime' do
          expect(@result).to eq DateTime.parse(input)
        end
      end

      describe 'when a float is given' do
        let(:input) { 2332.903007 }

        it 'raises error' do
          expect(@result).to eq Time.at(input).to_datetime
        end
      end

      describe 'when a fixnum is given' do
        let(:input) { 34_322 }

        it 'raises error' do
          expect(@result).to eq Time.at(input).to_datetime
        end
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into DateTime"
          end
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into DateTime"
          end
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into DateTime"
          end
        end
      end

      describe "when a string that doesn't represent a date is given" do
        let(:input) { 'crab' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into DateTime"
          end
        end
      end

      describe "when an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert into DateTime"
          end
        end
      end

      describe "when an object that doesn't implement #to_s?" do
        let(:input) { BaseObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.DateTime(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.DateTime(input)
          rescue => e
            expect(e.message).to eq "can't convert into DateTime"
          end
        end
      end
    end
  end

  describe '.Time' do
    before do
      class Epoch
        def to_time
          Time.at(0)
        end
      end

      BaseObject = Class.new(BasicObject) do
        def respond_to?(_method_name)
          false
        end
      end
    end

    after do
      Object.send(:remove_const, :Epoch)
      Object.send(:remove_const, :BaseObject)
    end

    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.Time(input)
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'returns the input' do
          expect(@result).to eq input
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'returns time' do
          expect(@result).to eq input.to_time
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'returns time' do
          expect(@result).to eq input.to_time
        end
      end

      describe 'when a string that represents a date is given' do
        let(:input) { '2014-04-18' }

        it 'returns time' do
          expect(@result).to eq Time.parse(input)
        end
      end

      describe 'when a string that represents a timestamp is given' do
        let(:input) { '2014-04-18 15:45:12' }

        it 'returns time' do
          expect(@result).to eq Time.parse(input)
        end
      end

      describe 'when an object that implements #to_time is given' do
        let(:input) { Epoch.new }

        it 'returns time' do
          expect(@result).to eq Time.at(0)
        end
      end

      describe 'when a string that represent a hour is given' do
        let(:input) { '15:47' }

        it 'returns a time' do
          expect(@result).to eq Time.parse(input)
        end
      end

      describe 'when a fixnum is given' do
        let(:input) { 38_922 }

        it 'returns a time' do
          expect(@result).to eq Time.at(input)
        end
      end

      describe 'when a float is given' do
        let(:input) { 1332.9423843 }

        it 'returns a time' do
          expect(@result).to eq Time.at(input)
        end
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Time"
          end
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Time"
          end
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Time"
          end
        end
      end

      describe "when a string that doesn't represent a date is given" do
        let(:input) { 'boat' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert #{input.inspect} into Time"
          end
        end
      end

      describe "when an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert into Time"
          end
        end
      end

      describe "when an object that doesn't implement #to_s" do
        let(:input) { BaseObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Time(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Time(input)
          rescue => e
            expect(e.message).to eq "can't convert into Time"
          end
        end
      end
    end
  end

  describe '.Pathname' do
    describe 'successful operations' do
      before do
        class RootPath
          def to_str
            '/'
          end
        end

        class HomePath
          def to_pathname
            Pathname.new Dir.home
          end
        end

        @result = Hanami::Utils::Kernel.Pathname(input)
      end

      after do
        Object.send(:remove_const, :RootPath)
        Object.send(:remove_const, :HomePath)
      end

      describe 'when a pathname is given' do
        let(:input) { Pathname.new('.') }

        it 'returns the input' do
          expect(@result).to eq input
        end
      end

      describe 'when a string is given' do
        let(:input) { '..' }

        it 'returns a pathname' do
          expect(@result).to eq Pathname.new(input)
        end
      end

      describe 'when an object that implements to_pathname is given' do
        let(:input) { HomePath.new }

        it 'returns a pathname' do
          expect(@result).to eq Pathname.new(Dir.home)
        end
      end

      describe 'when an object that implements to_str is given' do
        let(:input) { RootPath.new }

        it 'returns a pathname' do
          expect(@result).to eq Pathname.new('/')
        end
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when a number is given' do
        let(:input) { 12 }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end
      end

      describe "when an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Pathname(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Pathname(input)
          rescue => e
            expect(e.message).to eq "can't convert into Pathname"
          end
        end
      end
    end
  end

  describe '.Symbol' do
    describe 'successful operations' do
      before do
        class StatusSymbol
          def to_sym
            :success
          end
        end

        @result = Hanami::Utils::Kernel.Symbol(input)
      end

      after do
        Object.send(:remove_const, :StatusSymbol)
      end

      describe 'when a symbol is given' do
        let(:input) { :hello }

        it 'returns a symbol' do
          expect(@result).to eq :hello
        end
      end

      describe 'when a string is given' do
        let(:input) { 'hello' }

        it 'returns a symbol' do
          expect(@result).to eq :hello
        end
      end

      describe 'when an object that implements #to_sym' do
        let(:input) { StatusSymbol.new }

        it 'returns a symbol' do
          expect(@result).to eq :success
        end
      end
    end

    describe 'failure operations' do
      describe 'when nil is given' do
        let(:input) { nil }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when empty string is given' do
        let(:input) { '' }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when true is given' do
        let(:input) { true }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when false is given' do
        let(:input) { false }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when a number is given' do
        let(:input) { 12 }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when a date is given' do
        let(:input) { Date.today }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when a datetime is given' do
        let(:input) { DateTime.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe 'when a time is given' do
        let(:input) { Time.now }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end
      end

      describe "when an object that doesn't implement #respond_to?" do
        let(:input) { BasicObject.new }

        it 'raises error' do
          expect { Hanami::Utils::Kernel.Symbol(input) }.to raise_error TypeError
        end

        it 'returns useful informations about the failure' do
          begin
            Hanami::Utils::Kernel.Symbol(input)
          rescue => e
            expect(e.message).to eq "can't convert into Symbol"
          end
        end
      end
    end
  end

  describe '.numeric?' do
    describe 'successful operations' do
      before do
        @result = Hanami::Utils::Kernel.numeric?(input)
      end

      describe 'when a numeric in symbol is given' do
        let(:input) { :'123' }

        it 'returns a true' do
          expect(@result).to eq true
        end
      end

      describe 'when a symbol is given' do
        let(:input) { :hello }

        it 'returns false' do
          expect(@result).to eq false
        end
      end

      describe 'when a numeric in string is given' do
        let(:input) { '123' }

        it 'returns a symbol' do
          expect(@result).to eq true
        end
      end

      describe 'when a string is given' do
        let(:input) { 'hello' }

        it 'returns a symbol' do
          expect(@result).to eq false
        end
      end

      describe 'when a numeric is given' do
        let(:input) { 123 }

        it 'returns a symbol' do
          expect(@result).to eq true
        end
      end
    end
  end
end
