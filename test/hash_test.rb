require 'test_helper'
require 'bigdecimal'
require 'hanami/utils/hash'

describe Hanami::Utils::Hash do
  describe '#initialize' do
    let(:input_to_hash) do
      Class.new do
        def to_hash
          Hash[foo: 'bar']
        end
      end.new
    end

    let(:input_to_h) do
      Class.new do
        def to_h
          Hash[head: 'tail']
        end
      end.new
    end

    it 'holds values passed to the constructor' do
      hash = Hanami::Utils::Hash.new('foo' => 'bar')
      hash['foo'].must_equal('bar')
    end

    it 'assigns default via block' do
      hash = Hanami::Utils::Hash.new { |h, k| h[k] = [] }
      hash['foo'].push 'bar'

      hash.must_equal('foo' => ['bar'])
    end

    it 'accepts a Hanami::Utils::Hash' do
      arg  = Hanami::Utils::Hash.new('foo' => 'bar')
      hash = Hanami::Utils::Hash.new(arg)

      hash.to_h.must_be_kind_of(::Hash)
    end

    it 'accepts object that implements #to_hash' do
      hash = Hanami::Utils::Hash.new(input_to_hash)

      hash.to_h.must_equal(input_to_hash.to_hash)
    end

    it "raises error when object doesn't implement #to_hash" do
      lambda do
        Hanami::Utils::Hash.new(input_to_h)
      end.must_raise(NoMethodError)
    end
  end

  describe '#symbolize!' do
    it 'symbolize keys' do
      hash = Hanami::Utils::Hash.new('fub' => 'baz')
      hash.symbolize!

      hash['fub'].must_be_nil
      hash[:fub].must_equal('baz')
    end

    it 'does not symbolize nested hashes' do
      hash = Hanami::Utils::Hash.new('nested' => { 'key' => 'value' })
      hash.symbolize!

      hash[:nested].keys.must_equal(['key'])
    end
  end

  describe '#deep_symbolize!' do
    it 'symbolize keys' do
      hash = Hanami::Utils::Hash.new('fub' => 'baz')
      hash.deep_symbolize!

      hash['fub'].must_be_nil
      hash[:fub].must_equal('baz')
    end

    it 'symbolizes nested hashes' do
      hash = Hanami::Utils::Hash.new('nested' => { 'key' => 'value' })
      hash.deep_symbolize!

      hash[:nested].must_be_kind_of Hanami::Utils::Hash
      hash[:nested][:key].must_equal('value')
    end

    it 'symbolizes deep nested hashes' do
      hash = Hanami::Utils::Hash.new('nested1' => { 'nested2' => { 'nested3' => { 'key' => 1 } } })
      hash.deep_symbolize!

      hash.keys.must_equal([:nested1])

      hash1 = hash[:nested1]
      hash1.keys.must_equal([:nested2])

      hash2 = hash1[:nested2]
      hash2.keys.must_equal([:nested3])

      hash3 = hash2[:nested3]
      hash3.keys.must_equal([:key])

      hash3[:key].must_equal(1)
    end

    it 'symbolize nested Hanami::Utils::Hashes' do
      nested = Hanami::Utils::Hash.new('key' => 'value')
      hash = Hanami::Utils::Hash.new('nested' => nested)
      hash.deep_symbolize!

      hash[:nested].must_be_kind_of Hanami::Utils::Hash
      hash[:nested][:key].must_equal('value')
    end

    it 'symbolize nested object that responds to to_hash' do
      nested = Hanami::Utils::Hash.new('metadata' => WrappingHash.new('coverage' => 100))
      nested.deep_symbolize!

      nested[:metadata].must_be_kind_of Hanami::Utils::Hash
      nested[:metadata][:coverage].must_equal(100)
    end

    it 'symbolize nested array' do
      hash = Hanami::Utils::Hash.new('foo' => [{ 'bar' => 'baz' }, { 'bat' => 'quux' }])

      hash.deep_symbolize!

      hash[:foo].first['bar'].must_be_nil
      hash[:foo].last['bat'].must_be_nil

      hash[:foo].first[:bar].must_equal('baz')
      hash[:foo].last[:bat].must_equal('quux')
    end

    it "doesn't try to symbolize nested objects" do
      hash = Hanami::Utils::Hash.new('foo' => ['bar'])
      hash.deep_symbolize!

      hash[:foo].must_equal(['bar'])
    end
  end

  describe '#stringify!' do
    it 'covert keys to strings' do
      hash = Hanami::Utils::Hash.new(fub: 'baz')
      hash.stringify!

      hash[:fub].must_be_nil
      hash['fub'].must_equal('baz')
    end

    it 'stringifies nested hashes' do
      hash = Hanami::Utils::Hash.new(nested: { key: 'value' })
      hash.stringify!

      hash['nested'].must_be_kind_of Hanami::Utils::Hash
      hash['nested']['key'].must_equal('value')
    end

    it 'stringifies nested Hanami::Utils::Hashes' do
      nested = Hanami::Utils::Hash.new(key: 'value')
      hash = Hanami::Utils::Hash.new(nested: nested)
      hash.stringify!

      hash['nested'].must_be_kind_of Hanami::Utils::Hash
      hash['nested']['key'].must_equal('value')
    end

    it 'stringifies nested object that responds to to_hash' do
      nested = Hanami::Utils::Hash.new(metadata: WrappingHash.new(coverage: 100))
      nested.stringify!

      nested['metadata'].must_be_kind_of Hanami::Utils::Hash
      nested['metadata']['coverage'].must_equal(100)
    end
  end

  describe '#deep_dup' do
    it 'returns an instance of Utils::Hash' do
      duped = Hanami::Utils::Hash.new('foo' => 'bar').deep_dup
      duped.must_be_kind_of(Hanami::Utils::Hash)
    end

    it 'returns a hash with duplicated values' do
      hash  = Hanami::Utils::Hash.new('foo' => 'bar', 'baz' => 'x')
      duped = hash.deep_dup

      duped['foo'] = nil
      duped['baz'].upcase!

      hash['foo'].must_equal('bar')
      hash['baz'].must_equal('x')
    end

    it "doesn't try to duplicate value that can't perform this operation" do
      original = {
        'nil'        => nil,
        'false'      => false,
        'true'       => true,
        'symbol'     => :symbol,
        'fixnum'     => 23,
        'bignum'     => 13_289_301_283**2,
        'float'      => 1.0,
        'complex'    => Complex(0.3),
        'bigdecimal' => BigDecimal.new('12.0001'),
        'rational'   => Rational(0.3)
      }

      hash  = Hanami::Utils::Hash.new(original)
      duped = hash.deep_dup

      duped.must_equal(original)
      duped.object_id.wont_equal(original.object_id)
    end

    it 'returns a hash with nested duplicated values' do
      hash  = Hanami::Utils::Hash.new('foo' => { 'bar' => 'baz' }, 'x' => Hanami::Utils::Hash.new('y' => 'z'))
      duped = hash.deep_dup

      duped['foo']['bar'].reverse!
      duped['x']['y'].upcase!

      hash['foo']['bar'].must_equal('baz')
      hash['x']['y'].must_equal('z')
    end

    it 'preserves original class' do
      duped = Hanami::Utils::Hash.new('foo' => {}, 'x' => Hanami::Utils::Hash.new).deep_dup

      duped['foo'].must_be_kind_of(::Hash)
      duped['x'].must_be_kind_of(Hanami::Utils::Hash)
    end
  end

  describe 'hash interface' do
    it 'returns a new Hanami::Utils::Hash for methods which return a ::Hash' do
      hash   = Hanami::Utils::Hash.new('a' => 1)
      result = hash.clear

      assert hash.empty?
      result.must_be_kind_of(Hanami::Utils::Hash)
    end

    it 'returns a value that is compliant with ::Hash return value' do
      hash   = Hanami::Utils::Hash.new('a' => 1)
      result = hash.assoc('a')

      result.must_equal ['a', 1]
    end

    it 'responds to whatever ::Hash responds to' do
      hash = Hanami::Utils::Hash.new('a' => 1)

      hash.must_respond_to :rehash
      hash.wont_respond_to :unknown_method
    end

    it 'accepts blocks for methods' do
      hash   = Hanami::Utils::Hash.new('a' => 1)
      result = hash.delete_if { |k, _| k == 'a' }

      assert result.empty?
    end

    describe '#to_h' do
      it 'returns a ::Hash' do
        actual = Hanami::Utils::Hash.new('a' => 1).to_h
        actual.must_equal('a' => 1)
      end

      it 'returns nested ::Hash' do
        hash = {
          tutorial: {
            instructions: [
              { title: 'foo',  body: 'bar' },
              { title: 'hoge', body: 'fuga' }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash)
        utils_hash.wont_be_kind_of(::Hash)

        actual = utils_hash.to_h
        actual.must_equal(hash)

        actual[:tutorial].must_be_kind_of(::Hash)
        actual[:tutorial][:instructions].each do |h|
          h.must_be_kind_of(::Hash)
        end
      end

      it 'returns nested ::Hash (when symbolized)' do
        hash = {
          'tutorial' => {
            'instructions' => [
              { 'title' => 'foo',  'body' => 'bar' },
              { 'title' => 'hoge', 'body' => 'fuga' }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash).deep_symbolize!
        utils_hash.wont_be_kind_of(::Hash)

        actual = utils_hash.to_h
        actual.must_equal(hash)

        actual[:tutorial].must_be_kind_of(::Hash)
        actual[:tutorial][:instructions].each do |h|
          h.must_be_kind_of(::Hash)
        end
      end

      it 'prevents information escape' do
        actual = Hanami::Utils::Hash.new('a' => 1)
        hash   = actual.to_h
        hash['b'] = 2

        actual.to_h.must_equal('a' => 1)
      end

      it 'prevents information escape for nested hash'
      # it 'prevents information escape for nested hash' do
      #   actual  = Hanami::Utils::Hash.new({'a' => {'b' => 2}})
      #   hash    = actual.to_h
      #   subhash = hash['a']
      #   subhash.merge!('c' => 3)

      #   actual.to_h.must_equal({'a' => {'b' => 2}})
      # end

      it 'serializes nested objects that respond to to_hash' do
        nested = Hanami::Utils::Hash.new(metadata: WrappingHash.new(coverage: 100))
        nested.to_h.must_equal(metadata: { coverage: 100 })
      end
    end

    describe '#to_hash' do
      it 'returns a ::Hash' do
        actual = Hanami::Utils::Hash.new('a' => 1).to_hash
        actual.must_equal('a' => 1)
      end

      it 'returns nested ::Hash' do
        hash = {
          tutorial: {
            instructions: [
              { title: 'foo',  body: 'bar' },
              { title: 'hoge', body: 'fuga' }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash)
        utils_hash.wont_be_kind_of(::Hash)

        actual = utils_hash.to_h
        actual.must_equal(hash)

        actual[:tutorial].must_be_kind_of(::Hash)
        actual[:tutorial][:instructions].each do |h|
          h.must_be_kind_of(::Hash)
        end
      end

      it 'returns nested ::Hash (when symbolized)' do
        hash = {
          'tutorial' => {
            'instructions' => [
              { 'title' => 'foo',  'body' => 'bar' },
              { 'title' => 'hoge', 'body' => 'fuga' }
            ]
          }
        }

        utils_hash = Hanami::Utils::Hash.new(hash).deep_symbolize!
        utils_hash.wont_be_kind_of(::Hash)

        actual = utils_hash.to_h
        actual.must_equal(hash)

        actual[:tutorial].must_be_kind_of(::Hash)
        actual[:tutorial][:instructions].each do |h|
          h.must_be_kind_of(::Hash)
        end
      end

      it 'prevents information escape' do
        actual = Hanami::Utils::Hash.new('a' => 1)
        hash   = actual.to_hash
        hash['b'] = 2

        actual.to_hash.must_equal('a' => 1)
      end
    end

    describe '#to_a' do
      it 'returns an ::Array' do
        actual = Hanami::Utils::Hash.new('a' => 1).to_a
        actual.must_equal([['a', 1]])
      end

      it 'prevents information escape' do
        actual = Hanami::Utils::Hash.new('a' => 1)
        array  = actual.to_a
        array.push(['b', 2])

        actual.to_a.must_equal([['a', 1]])
      end
    end

    describe 'equality' do
      it 'has a working equality' do
        hash  = Hanami::Utils::Hash.new('a' => 1)
        other = Hanami::Utils::Hash.new('a' => 1)

        assert hash == other
      end

      it 'has a working equality with raw hashes' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        assert hash == { 'a' => 1 }
      end
    end

    describe 'case equality' do
      it 'has a working case equality' do
        hash  = Hanami::Utils::Hash.new('a' => 1)
        other = Hanami::Utils::Hash.new('a' => 1)

        assert hash === other # rubocop:disable Style/CaseEquality
      end

      it 'has a working case equality with raw hashes' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        assert hash === { 'a' => 1 } # rubocop:disable Style/CaseEquality
      end
    end

    describe 'value equality' do
      it 'has a working value equality' do
        hash  = Hanami::Utils::Hash.new('a' => 1)
        other = Hanami::Utils::Hash.new('a' => 1)

        assert hash.eql?(other)
      end

      it 'has a working value equality with raw hashes' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        assert hash.eql?('a' => 1)
      end
    end

    describe 'identity equality' do
      it 'has a working identity equality' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        assert hash.equal?(hash)
      end

      it 'has a working identity equality with raw hashes' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        assert !hash.equal?('a' => 1)
      end
    end

    describe '#hash' do
      it 'returns the same hash result of ::Hash' do
        expected = { 'l' => 23 }.hash
        actual   = Hanami::Utils::Hash.new('l' => 23).hash

        actual.must_equal expected
      end
    end

    describe '#inspect' do
      it 'returns the same output of ::Hash' do
        expected = { 'l' => 23, l: 23 }.inspect
        actual   = Hanami::Utils::Hash.new('l' => 23, l: 23).inspect

        actual.must_equal expected
      end
    end

    describe 'unknown method' do
      it 'raises error' do
        begin
          Hanami::Utils::Hash.new('l' => 23).party!
        rescue NoMethodError => e
          e.message.must_equal %(undefined method `party!' for {\"l\"=>23}:Hanami::Utils::Hash)
        end
      end

      # See: https://github.com/hanami/utils/issues/48
      it 'returns the correct object when a NoMethodError is raised' do
        hash = Hanami::Utils::Hash.new('a' => 1)
        exception_message = "undefined method `foo' for 1:Fixnum"

        exception = -> { hash.all? { |_, v| v.foo } }.must_raise NoMethodError
        exception.message.must_match exception_message
      end
    end
  end
end
