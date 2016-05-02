require 'test_helper'
require 'bigdecimal'
require 'hanami/utils/attributes'

describe Hanami::Utils::Attributes do
  describe '#initialize' do
    before do
      class AttributesSet
        def to_h
          {a: 1}
        end
      end
    end

    after do
      Object.__send__(:remove_const, :AttributesSet)
    end

    it 'accepts an object that implements #to_h' do
      attributes = Hanami::Utils::Attributes.new(AttributesSet.new)
      attributes.to_h.must_equal({'a' => 1})
    end

    it "ignores hash default" do
      attributes = Hanami::Utils::Attributes.new{|h,k| h[k] = [] }
      attributes.get('uknown').must_be_nil
    end

    it 'recursively stringify keys' do
      attributes = Hanami::Utils::Attributes.new({a: 1, b: { 2 => [3, 4] }})
      attributes.to_h.must_equal({'a'=>1, 'b'=>{'2'=>[3,4]}})
    end
  end

  describe '#get' do
    it 'returns value associated to the given key (string)' do
      attributes = Hanami::Utils::Attributes.new('foo' => 'bar')
      attributes.get('foo').must_equal 'bar'
      attributes.get(:foo).must_equal  'bar'
    end

    it 'returns value associated to the given key (symbol)' do
      attributes = Hanami::Utils::Attributes.new(foo: 'bar')
      attributes.get(:foo).must_equal  'bar'
      attributes.get('foo').must_equal 'bar'
    end

    it 'returns value associated to the given key (number)' do
      attributes = Hanami::Utils::Attributes.new( 23 => 'foo')
      attributes.get(23).must_equal   'foo'
      attributes.get('23').must_equal 'foo'
    end

    it 'allows deep indifferent access' do
      attributes = Hanami::Utils::Attributes.new(foo: {baz: 'bar'})
      attributes.get(:foo).get(:baz).must_equal 'bar'
      attributes.get(:foo).get('baz').must_equal 'bar'
      attributes.get('foo').get(:baz).must_equal 'bar'
      attributes.get('foo').get('baz').must_equal 'bar'
    end

    it 'allows deep access via nested key string' do
      attributes = Hanami::Utils::Attributes.new(foo: {baz: 'bar'})
      attributes.get('foo.baz').must_equal 'bar'
    end

    it 'correctly handles Ruby falsey' do
      attributes = Hanami::Utils::Attributes.new('foo' => false)
      attributes.get(:foo).must_equal  false
      attributes.get('foo').must_equal false

      attributes = Hanami::Utils::Attributes.new(foo: false)
      attributes.get(:foo).must_equal false
    end

    it 'ignores hash default' do
      attributes = Hanami::Utils::Attributes.new{|h,k| h[k] = [] }
      attributes.get('foo').must_be_nil
      attributes.get(:foo).must_be_nil
    end

    it 'overrides clashing keys' do
      attributes = Hanami::Utils::Attributes.new('foo' => 'bar', foo: 'baz')
      attributes.get('foo').must_equal 'baz'
      attributes.get(:foo).must_equal  'baz'
    end
  end

  describe '#[]' do
    it 'returns value associated to the given key (string)' do
      attributes = Hanami::Utils::Attributes.new('foo' => 'bar')
      attributes['foo'].must_equal 'bar'
      attributes[:foo].must_equal  'bar'
    end

    it 'returns value associated to the given key (symbol)' do
      attributes = Hanami::Utils::Attributes.new(foo: 'bar')
      attributes[:foo].must_equal  'bar'
      attributes['foo'].must_equal 'bar'
    end

    it 'returns value associated to the given key (number)' do
      attributes = Hanami::Utils::Attributes.new( 23 => 'foo')
      attributes[23].must_equal   'foo'
      attributes['23'].must_equal 'foo'
    end

    it 'allows deep indifferent access' do
      attributes = Hanami::Utils::Attributes.new(foo: {baz: 'bar'})
      attributes[:foo][:baz].must_equal 'bar'
      attributes[:foo]['baz'].must_equal 'bar'
      attributes['foo'][:baz].must_equal 'bar'
      attributes['foo']['baz'].must_equal 'bar'
    end

    it 'allows deep access via nested key string' do
      attributes = Hanami::Utils::Attributes.new(foo: {baz: 'bar'})
      attributes['foo.baz'].must_equal 'bar'
    end

    it 'correctly handles Ruby falsey' do
      attributes = Hanami::Utils::Attributes.new('foo' => false)
      attributes[:foo].must_equal  false
      attributes['foo'].must_equal false

      attributes = Hanami::Utils::Attributes.new(foo: false)
      attributes[:foo].must_equal false
    end

    it 'ignores hash default' do
      attributes = Hanami::Utils::Attributes.new{|h,k| h[k] = [] }
      attributes['foo'].must_be_nil
      attributes[:foo].must_be_nil
    end

    it 'overrides clashing keys' do
      attributes = Hanami::Utils::Attributes.new('foo' => 'bar', foo: 'baz')
      attributes['foo'].must_equal 'baz'
      attributes[:foo].must_equal  'baz'
    end
  end

  describe '#set' do
    it 'is a void operation' do
      Hanami::Utils::Attributes.new.set('foo', 11).must_be_nil
    end

    it 'sets a value (string)' do
      attributes = Hanami::Utils::Attributes.new
      attributes.set('foo', 'bar')

      attributes.get('foo').must_equal 'bar'
      attributes.get(:foo).must_equal  'bar'
    end

    it 'sets a value (symbol)' do
      attributes = Hanami::Utils::Attributes.new
      attributes.set(:foo, 'bar')

      attributes.get('foo').must_equal 'bar'
      attributes.get(:foo).must_equal  'bar'
    end

    it 'sets a value (number)' do
      attributes = Hanami::Utils::Attributes.new
      attributes.set(23, 'bar')

      attributes.get(23).must_equal   'bar'
      attributes.get('23').must_equal 'bar'
    end
  end

  describe '#to_h' do
    before do
      @value = Class.new do
        def hanami_nested_attributes?
          true
        end

        def to_h
          {'foo' => 'bar'}
        end
      end.new
    end

    it 'returns an instance of ::Hanami::Utils::Hash' do
      attributes = Hanami::Utils::Attributes.new
      attributes.to_h.must_be_kind_of(::Hash)
    end

    it 'returns a hash serialization' do
      attributes = Hanami::Utils::Attributes.new(foo: 'bar')
      attributes.to_h.must_equal({'foo' => 'bar'})
    end

    it 'prevents information escape' do
      actual = Hanami::Utils::Attributes.new({'a' => 1})
      hash   = actual.to_h
      hash.merge!('b' => 2)

      actual.get('b').must_be_nil
    end

    it 'forces ::Hanami::Utils::Hash values when a validations nested attributes is given' do
      attributes = Hanami::Utils::Attributes.new(val: @value)
      actual     = attributes.to_h

      actual.must_equal({'val' => { 'foo' => 'bar'}})
      actual['val'].must_be_kind_of(::Hash)
    end

    # Bug
    # See: https://github.com/hanami/validations/issues/58#issuecomment-99144243
    it 'fallbacks to the original value if TypeError is raised' do
      attributes = Hanami::Utils::Attributes.new(val: [1, 2])
      actual     = attributes.to_h

      actual.must_equal({'val' => [1, 2]})
      actual['val'].must_be_kind_of(Array)
    end
  end
end
