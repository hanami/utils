require 'test_helper'
require 'lotus/utils/hash'

describe Lotus::Utils::Hash do
  describe '#initialize' do
    it 'holds values passed to the constructor' do
      hash = Lotus::Utils::Hash.new('foo' => 'bar')
      hash['foo'].must_equal('bar')
    end

    it 'assigns default via block' do
      hash = Lotus::Utils::Hash.new {|h,k| h[k] = []}
      hash['foo'].push 'bar'

      hash.must_equal({'foo' => ['bar']})
    end

    it 'accepts a Lotus::Utils::Hash' do
      arg  = Lotus::Utils::Hash.new('foo' => 'bar')
      hash = Lotus::Utils::Hash.new(arg)

      hash.to_h.must_be_kind_of(::Hash)
    end
  end

  describe '#symbolize!' do
    it 'symbolize keys' do
      hash = Lotus::Utils::Hash.new('fub' => 'baz')
      hash.symbolize!

      hash['fub'].must_be_nil
      hash[:fub].must_equal('baz')
    end

    it 'symbolize nested hashes' do
      hash = Lotus::Utils::Hash.new('nested' => {'key' => 'value'})
      hash.symbolize!

      hash[:nested].must_be_kind_of Lotus::Utils::Hash
      hash[:nested][:key].must_equal('value')
    end
  end

  describe 'hash interface' do
    it 'returns a new Lotus::Utils::Hash for methods which return a ::Hash' do
      hash   = Lotus::Utils::Hash.new({'a' => 1})
      result = hash.clear

      assert hash.empty?
      result.must_be_kind_of(Lotus::Utils::Hash)
    end

    it 'returns a value that is compliant with ::Hash return value' do
      hash   = Lotus::Utils::Hash.new({'a' => 1})
      result = hash.assoc('a')

      result.must_equal ['a', 1]
    end

    it 'responds to whatever ::Hash responds to' do
      hash   = Lotus::Utils::Hash.new({'a' => 1})

      hash.must_respond_to :rehash
      hash.wont_respond_to :unknown_method
    end

    it 'accepts blocks for methods' do
      hash   = Lotus::Utils::Hash.new({'a' => 1})
      result = hash.delete_if {|k, _| k == 'a' }

      assert result.empty?
    end

    describe '#to_h' do
      it 'returns a ::Hash' do
        actual = Lotus::Utils::Hash.new({'a' => 1}).to_h
        actual.must_equal({'a' => 1})
      end

      it 'prevents information escape' do
        actual = Lotus::Utils::Hash.new({'a' => 1})
        hash   = actual.to_h
        hash.merge!('b' => 2)

        actual.to_h.must_equal({'a' => 1})
      end
    end

    describe '#to_hash' do
      it 'returns a ::Hash' do
        actual = Lotus::Utils::Hash.new({'a' => 1}).to_hash
        actual.must_equal({'a' => 1})
      end

      it 'prevents information escape' do
        actual = Lotus::Utils::Hash.new({'a' => 1})
        hash   = actual.to_hash
        hash.merge!('b' => 2)

        actual.to_hash.must_equal({'a' => 1})
      end
    end

    describe '#to_a' do
      it 'returns an ::Array' do
        actual = Lotus::Utils::Hash.new({'a' => 1}).to_a
        actual.must_equal([['a', 1]])
      end

      it 'prevents information escape' do
        actual = Lotus::Utils::Hash.new({'a' => 1})
        array  = actual.to_a
        array.push(['b', 2])

        actual.to_a.must_equal([['a', 1]])
      end
    end

    describe 'equality' do
      it 'has a working equality' do
        hash  = Lotus::Utils::Hash.new({'a' => 1})
        other = Lotus::Utils::Hash.new({'a' => 1})

        assert hash == other
      end

      it 'has a working equality with raw hashes' do
        hash = Lotus::Utils::Hash.new({'a' => 1})
        assert hash == {'a' => 1}
      end
    end

    describe 'case equality' do
      it 'has a working case equality' do
        hash  = Lotus::Utils::Hash.new({'a' => 1})
        other = Lotus::Utils::Hash.new({'a' => 1})

        assert hash === other
      end

      it 'has a working case equality with raw hashes' do
        hash = Lotus::Utils::Hash.new({'a' => 1})
        assert hash === {'a' => 1}
      end
    end

    describe 'value equality' do
      it 'has a working value equality' do
        hash  = Lotus::Utils::Hash.new({'a' => 1})
        other = Lotus::Utils::Hash.new({'a' => 1})

        assert hash.eql?(other)
      end

      it 'has a working value equality with raw hashes' do
        hash = Lotus::Utils::Hash.new({'a' => 1})
        assert hash.eql?({'a' => 1})
      end
    end

    describe 'identity equality' do
      it 'has a working identity equality' do
        hash  = Lotus::Utils::Hash.new({'a' => 1})
        assert hash.equal?(hash)
      end

      it 'has a working identity equality with raw hashes' do
        hash  = Lotus::Utils::Hash.new({'a' => 1})
        assert !hash.equal?({'a' => 1})
      end
    end

    describe '#hash' do
      it 'returns the same hash result of ::Hash' do
        expected = {'l' => 23}.hash
        actual   = Lotus::Utils::Hash.new({'l' => 23}).hash

        actual.must_equal expected
      end
    end

    describe '#inspect' do
      it 'returns the same output of ::Hash' do
        expected = {'l' => 23, l: 23}.inspect
        actual   = Lotus::Utils::Hash.new({'l' => 23, l: 23}).inspect

        actual.must_equal expected
      end
    end

    describe 'unknown method' do
      it 'raises error' do
        begin
          Lotus::Utils::Hash.new('l' => 23).party!
        rescue NoMethodError => e
          e.message.must_equal %(undefined method `party!' for {\"l\"=>23}:Lotus::Utils::Hash)
        end
      end
    end
  end
end
