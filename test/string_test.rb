require 'test_helper'
require 'hanami/utils'
require 'hanami/utils/string'

describe Hanami::Utils::String do
  describe '#titleize' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('hanami').titleize.must_be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate self' do
      string = Hanami::Utils::String.new('hanami')
      string.titleize
      string.must_equal 'hanami'
    end

    it 'returns an titleized string' do
      Hanami::Utils::String.new('hanami').titleize.must_equal 'Hanami'
      Hanami::Utils::String.new('HanamiUtils').titleize.must_equal  'Hanami Utils'
      Hanami::Utils::String.new('hanami utils').titleize.must_equal 'Hanami Utils'
      Hanami::Utils::String.new('hanami_utils').titleize.must_equal 'Hanami Utils'
      Hanami::Utils::String.new('hanami-utils').titleize.must_equal 'Hanami Utils'
      Hanami::Utils::String.new("hanami' utils").titleize.must_equal "Hanami' Utils"
      Hanami::Utils::String.new("hanami’ utils").titleize.must_equal "Hanami’ Utils"
      Hanami::Utils::String.new("hanami` utils").titleize.must_equal "Hanami` Utils"
      # Ruby's upcase works only with ASCII chars.
      # Hanami::Utils::String.new("è vero?").titleize.must_equal "È Vero?"
    end
  end

  describe '#capitalize' do
    # it 'returns an instance of Hanami::Utils::String' do
    #   Hanami::Utils::String.new('hanami').capitalize.must_be_kind_of(Hanami::Utils::String)
    # end

    # it "doesn't mutate self" do
    #   string = Hanami::Utils::String.new('hanami')
    #   string.capitalize
    #   string.must_equal 'hanami'
    # end

    it 'returns an capitalized string' do
      Hanami::Utils::String.new('hanami').capitalize.must_equal 'Hanami'
      Hanami::Utils::String.new('HanamiUtils').capitalize.must_equal  'Hanami utils'
      Hanami::Utils::String.new('hanami utils').capitalize.must_equal 'Hanami utils'
      Hanami::Utils::String.new('hanami_utils').capitalize.must_equal 'Hanami utils'
      Hanami::Utils::String.new('hanami-utils').capitalize.must_equal 'Hanami utils'
      Hanami::Utils::String.new("hanami' utils").capitalize.must_equal "Hanami' utils"
      Hanami::Utils::String.new("hanami’ utils").capitalize.must_equal "Hanami’ utils"
      Hanami::Utils::String.new("hanami` utils").capitalize.must_equal "Hanami` utils"
      # Ruby's upcase works only with ASCII chars.
      # Hanami::Utils::String.new("è vero?").capitalize.must_equal "È vero?"
      Hanami::Utils::String.new('OneTwoThree').capitalize.must_equal   'One two three'
      Hanami::Utils::String.new('one Two three').capitalize.must_equal 'One two three'
      Hanami::Utils::String.new('one_two_three').capitalize.must_equal 'One two three'
      Hanami::Utils::String.new('one-two-three').capitalize.must_equal 'One two three'

      Hanami::Utils::String.new(:HanamiUtils).capitalize.must_equal    'Hanami utils'
      Hanami::Utils::String.new(:'hanami utils').capitalize.must_equal 'Hanami utils'
      Hanami::Utils::String.new(:hanami_utils).capitalize.must_equal   'Hanami utils'
      Hanami::Utils::String.new(:'hanami-utils').capitalize.must_equal 'Hanami utils'
    end
  end

  describe '#classify' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('hanami').classify.must_be_kind_of(Hanami::Utils::String)
    end

    it 'returns a classified string' do
      Hanami::Utils::String.new('hanami').classify.must_equal('Hanami')
      Hanami::Utils::String.new('hanami_router').classify.must_equal('HanamiRouter')
      Hanami::Utils::String.new('hanami-router').classify.must_equal('Hanami::Router')
      Hanami::Utils::String.new('hanami/router').classify.must_equal('Hanami::Router')
      Hanami::Utils::String.new('hanami::router').classify.must_equal('Hanami::Router')
      Hanami::Utils::String.new('hanami::router/base_object').classify.must_equal('Hanami::Router::BaseObject')
    end

    it 'returns a classified string from symbol' do
      Hanami::Utils::String.new(:hanami).classify.must_equal('Hanami')
      Hanami::Utils::String.new(:hanami_router).classify.must_equal('HanamiRouter')
      Hanami::Utils::String.new(:'hanami-router').classify.must_equal('Hanami::Router')
      Hanami::Utils::String.new(:'hanami/router').classify.must_equal('Hanami::Router')
      Hanami::Utils::String.new(:'hanami::router').classify.must_equal('Hanami::Router')
    end

    it 'does not remove capital letter in string' do
      Hanami::Utils::String.new('AwesomeProject').classify.must_equal('AwesomeProject')
    end
  end

  describe '#underscore' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('Hanami').underscore.must_be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      string.underscore
      string.must_equal 'Hanami'
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.new('Hanami')
      string.underscore.must_equal 'hanami'
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.new('HanamiView')
      string.underscore.must_equal 'hanami_view'
    end

    it 'substitutes double colons with path separators' do
      string = Hanami::Utils::String.new('Hanami::Utils::String')
      string.underscore.must_equal 'hanami/utils/string'
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.new('APIDoc')
      string.underscore.must_equal 'api_doc'
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.new('Lucky23Action')
      string.underscore.must_equal 'lucky23_action'
    end

    it 'handles dashes' do
      string = Hanami::Utils::String.new('hanami-utils')
      string.underscore.must_equal 'hanami_utils'
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.new('Hanami Utils')
      string.underscore.must_equal 'hanami_utils'
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.new('è vero')
      string.underscore.must_equal 'è_vero'
    end
  end

  describe '#dasherize' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('Hanami').dasherize.must_be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      string.dasherize
      string.must_equal 'Hanami'
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.new('Hanami')
      string.dasherize.must_equal 'hanami'
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.new('HanamiView')
      string.dasherize.must_equal 'hanami-view'
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.new('APIDoc')
      string.dasherize.must_equal 'api-doc'
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.new('Lucky23Action')
      string.dasherize.must_equal 'lucky23-action'
    end

    it 'handles underscores' do
      string = Hanami::Utils::String.new('hanami_utils')
      string.dasherize.must_equal 'hanami-utils'
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.new('Hanami Utils')
      string.dasherize.must_equal 'hanami-utils'
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.new('è vero')
      string.dasherize.must_equal 'è-vero'
    end
  end

  describe '#demodulize' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('Hanami').demodulize.must_be_kind_of(Hanami::Utils::String)
    end

    it 'returns the class name without the namespace' do
      Hanami::Utils::String.new('String').demodulize.must_equal('String')
      Hanami::Utils::String.new('Hanami::Utils::String').demodulize.must_equal('String')
    end
  end

  describe '#namespace' do
    it 'returns an instance of Hanami::Utils::String' do
      Hanami::Utils::String.new('Hanami').namespace.must_be_kind_of(Hanami::Utils::String)
    end

    it 'returns the top level module name' do
      Hanami::Utils::String.new('String').namespace.must_equal('String')
      Hanami::Utils::String.new('Hanami::Utils::String').namespace.must_equal('Hanami')
    end
  end

  describe '#tokenize' do
    before do
      @logger = []
    end

    it 'returns an instance of Hanami::Utils::String' do
      string = Hanami::Utils::String.new('Hanami::(Utils|App)')
      string.tokenize do |token|
        @logger.push token
      end

      @logger.each do |token|
        token.must_be_kind_of(Hanami::Utils::String)
      end
    end

    it 'calls the given block for each token occurrence' do
      string = Hanami::Utils::String.new('Hanami::(Utils|App)')
      string.tokenize do |token|
        @logger.push token
      end

      @logger.must_equal(['Hanami::Utils', 'Hanami::App'])
    end

    it 'guarantees the block to be called even when the token conditions are not met' do
      string = Hanami::Utils::String.new('Hanami')
      string.tokenize do |token|
        @logger.push token
      end

      @logger.must_equal(['Hanami'])
    end

    it 'returns nil' do
      result = Hanami::Utils::String.new('Hanami::(Utils|App)').tokenize { }
      result.must_be_nil
    end
  end

  describe '#pluralize' do
    before do
      @singular, @plural = *TEST_PLURALS.to_a.sample
    end

    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new(@singular).pluralize
      result.must_be_kind_of(Hanami::Utils::String)
    end

    it 'pluralizes string' do
      result = Hanami::Utils::String.new(@singular).pluralize
      result.must_equal(@plural)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@singular)

      string.pluralize.must_equal(@plural)
      string.must_equal(@singular)
    end
  end

  describe '#singularize' do
    before do
      @singular, @plural = *TEST_SINGULARS.to_a.sample
    end

    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new(@plural).singularize
      result.must_be_kind_of(Hanami::Utils::String)
    end

    it 'singularizes string' do
      result = Hanami::Utils::String.new(@plural).singularize
      result.must_equal(@singular)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@plural)

      string.singularize.must_equal(@singular)
      string.must_equal(@plural)
    end
  end

  describe '#rsub' do
    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new('authors/books/index').rsub(//, '')
      result.must_be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate original string' do
      string = Hanami::Utils::String.new('authors/books/index')
      string.rsub(/\//, '#')

      string.must_equal('authors/books/index')
    end

    it 'replaces rightmost instance (regexp)' do
      result = Hanami::Utils::String.new('authors/books/index').rsub(/\//, '#')
      result.must_equal('authors/books#index')
    end

    it 'replaces rightmost instance (string)' do
      result = Hanami::Utils::String.new('authors/books/index').rsub('/', '#')
      result.must_equal('authors/books#index')
    end

    it 'accepts Hanami::Utils::String as replacement' do
      replacement = Hanami::Utils::String.new('#')
      result      = Hanami::Utils::String.new('authors/books/index').rsub(/\//, replacement)

      result.must_equal('authors/books#index')
    end

    it 'returns the initial string no match' do
      result = Hanami::Utils::String.new('index').rsub(/\//, '#')
      result.must_equal('index')
    end
  end

  describe 'string interface' do
    it 'responds to ::String methods and returns a new Hanami::Utils::String' do
      string = Hanami::Utils::String.new("Hanami\n").chomp
      string.must_equal('Hanami')
      string.must_be_kind_of Hanami::Utils::String
    end

    it 'responds to ::String methods and only returns a new Hanami::Utils::String when the return value is a string' do
      string = Hanami::Utils::String.new('abcdef')
      string.casecmp('abcde').must_equal 1
    end

    it 'responds to whatever ::String responds to' do
      string = Hanami::Utils::String.new('abcdef')

      string.must_respond_to :reverse
      string.wont_respond_to :unknown_method
    end

    describe 'equality' do
      it 'has a working equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')

        assert string == other
      end

      it 'has a working equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        assert string == 'hanami'
      end
    end

    describe 'case equality' do
      it 'has a working case equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')
        assert string === other
      end

      it 'has a working case equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        assert string === 'hanami'
      end
    end

    describe 'value equality' do
      it 'has a working value equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')
        assert string.eql?(other)
      end

      it 'has a working value equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        assert string.eql?('hanami')
      end
    end

    describe 'identity equality' do
      it 'has a working identity equality' do
        string = Hanami::Utils::String.new('hanami')
        assert string.equal?(string)
      end

      it 'has a working identity equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        assert !string.equal?('hanami')
      end
    end

    describe '#hash' do
      it 'returns the same hash result of ::String' do
        expected = 'hello'.hash
        actual   = Hanami::Utils::String.new('hello').hash

        actual.must_equal expected
      end
    end
  end

  describe 'unknown method' do
    it 'raises error' do
      begin
        Hanami::Utils::String.new('one').yay!
      rescue NoMethodError => e
        e.message.must_equal %(undefined method `yay!' for "one":Hanami::Utils::String)
      end
    end

    # See: https://github.com/hanami/utils/issues/48
    it 'returns the correct object when a NoMethodError is raised' do
      string            = Hanami::Utils::String.new('/path/to/something')
      exception_message = %(undefined method `boom' for "/":String)

      exception = -> { string.gsub(/\//) { |s| s.boom }}.must_raise NoMethodError
      exception.message.must_equal exception_message
    end
  end
end
