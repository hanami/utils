require 'test_helper'
require 'hanami/utils/path_prefix'

describe Hanami::Utils::PathPrefix do
  it 'exposes itself as a string' do
    prefix = Hanami::Utils::PathPrefix.new
    assert prefix == '', "Expected #{ prefix } to equal ''"
  end

  it 'adds root prefix only when needed' do
    prefix = Hanami::Utils::PathPrefix.new('/fruits')
    assert prefix == '/fruits', "Expected #{ prefix } to equal '/fruits'"
  end

  describe '#join' do
    it 'returns a PathPrefix' do
      prefix = Hanami::Utils::PathPrefix.new('orders', '?').join('new')
      prefix.must_be_kind_of(Hanami::Utils::PathPrefix)
      prefix.__send__(:separator).must_equal('?')
    end

    it 'joins a string' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.join('peaches').must_equal '/fruits/peaches'
    end

    it 'joins a prefixed string' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.join('/cherries').must_equal '/fruits/cherries'
    end

    it 'joins a string that is the same as the prefix' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.join('fruits').must_equal '/fruits/fruits'
    end

    it 'joins a string when the root is blank' do
      prefix = Hanami::Utils::PathPrefix.new
      prefix.join('tea').must_equal '/tea'
    end

    it 'joins a prefixed string when the root is blank' do
      prefix = Hanami::Utils::PathPrefix.new
      prefix.join('/tea').must_equal '/tea'
    end

    it 'joins multiple strings' do
      prefix = Hanami::Utils::PathPrefix.new
      prefix.join('assets', 'application.js').must_equal '/assets/application.js'

      prefix = Hanami::Utils::PathPrefix.new('myapp')
      prefix.join('assets', 'application.js').must_equal '/myapp/assets/application.js'

      prefix = Hanami::Utils::PathPrefix.new('/myapp')
      prefix.join('/assets', 'application.js').must_equal '/myapp/assets/application.js'
    end

    it 'rejects entries that are matching separator' do
      prefix = Hanami::Utils::PathPrefix.new('/assets')
      prefix.join('/').must_equal '/assets'
    end

    it 'removes trailing occurrences of separator' do
      prefix = Hanami::Utils::PathPrefix.new('curcuma')
      prefix.join(nil).must_equal '/curcuma'
    end
  end

  describe '#relative_join' do
    it 'returns a PathPrefix' do
      prefix = Hanami::Utils::PathPrefix.new('orders', '&').relative_join('new')
      prefix.must_be_kind_of(Hanami::Utils::PathPrefix)
      prefix.__send__(:separator).must_equal('&')
    end

    it 'joins a string without prefixing with separator' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.relative_join('peaches').must_equal 'fruits/peaches'
    end

    it 'joins a prefixed string without prefixing with separator' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.relative_join('/cherries').must_equal 'fruits/cherries'
    end

    it 'joins a string when the root is blank without prefixing with separator' do
      prefix = Hanami::Utils::PathPrefix.new
      prefix.relative_join('tea').must_equal 'tea'
    end

    it 'joins a prefixed string when the root is blank and removes the prefix' do
      prefix = Hanami::Utils::PathPrefix.new
      prefix.relative_join('/tea').must_equal 'tea'
    end

    it 'joins a string with custom separator' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.relative_join('cherries', '_').must_equal 'fruits_cherries'
    end

    it 'joins a prefixed string without prefixing with custom separator' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      prefix.relative_join('_cherries', '_').must_equal 'fruits_cherries'
    end

    it 'changes all the occurences of the current separator with the given one' do
      prefix = Hanami::Utils::PathPrefix.new('?fruits', '?')
      prefix.relative_join('cherries', '_').must_equal 'fruits_cherries'
    end

    it 'removes trailing occurrences of separator' do
      prefix = Hanami::Utils::PathPrefix.new('jojoba')
      prefix.relative_join(nil).must_equal 'jojoba'
    end

    it 'rejects entries that are matching separator' do
      prefix = Hanami::Utils::PathPrefix.new('assets')
      prefix.relative_join('/').must_equal 'assets'
    end

    it 'raises error if the given separator is nil' do
      prefix = Hanami::Utils::PathPrefix.new('fruits')
      -> { prefix.relative_join('_cherries', nil) }.must_raise TypeError
    end
  end

  # describe '#resolve' do
  #   it 'resolves empty path' do
  #     prefix = Hanami::Utils::PathPrefix.new('')
  #     prefix.resolve.must_equal '/'
  #   end

  #   it 'resolves root path path' do
  #     prefix = Hanami::Utils::PathPrefix.new('/')
  #     prefix.resolve.must_equal '/'
  #   end

  #   it 'absolutize relative path' do
  #     prefix = Hanami::Utils::PathPrefix.new('coffees')
  #     prefix.resolve.must_equal '/coffees'
  #   end

  #   it 'leaves untouched absolute path' do
  #     prefix = Hanami::Utils::PathPrefix.new('/coffees')
  #     prefix.resolve.must_equal '/coffees'
  #   end

  #   it 'removes double leading slashes' do
  #     prefix = Hanami::Utils::PathPrefix.new('//coffees')
  #     prefix.resolve.must_equal '/coffees'
  #   end
  # end

  describe 'string interface' do
    describe 'equality' do
      it 'has a working equality' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        other  = Hanami::Utils::PathPrefix.new('hanami')

        assert string == other
      end

      it 'has a working equality with raw strings' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        assert string == 'hanami'
      end
    end

    describe 'case equality' do
      it 'has a working case equality' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        other  = Hanami::Utils::PathPrefix.new('hanami')
        assert string === other
      end

      it 'has a working case equality with raw strings' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        assert string === 'hanami'
      end
    end

    describe 'value equality' do
      it 'has a working value equality' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        other  = Hanami::Utils::PathPrefix.new('hanami')
        assert string.eql?(other)
      end

      it 'has a working value equality with raw strings' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        assert string.eql?('hanami')
      end
    end

    describe 'identity equality' do
      it 'has a working identity equality' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        assert string.equal?(string)
      end

      it 'has a working identity equality with raw strings' do
        string = Hanami::Utils::PathPrefix.new('hanami')
        assert !string.equal?('hanami')
      end
    end

    describe '#hash' do
      it 'returns the same hash result of ::String' do
        expected = 'hello'.hash
        actual   = Hanami::Utils::PathPrefix.new('hello').hash

        actual.must_equal expected
      end
    end
  end
end
