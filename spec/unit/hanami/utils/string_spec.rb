require 'hanami/utils/string'

RSpec.describe Hanami::Utils::String do
  describe '.titleize' do
    it '::String' do
      expect(Hanami::Utils::String.titleize('hanami')).to be_kind_of(::String)
    end

    it 'does not mutate self' do
      string = Hanami::Utils::String.new('hanami')
      Hanami::Utils::String.titleize(string)
      expect(string).to eq('hanami')
    end

    it 'returns an titleized string' do
      expect(Hanami::Utils::String.titleize('hanami')).to eq('Hanami')
      expect(Hanami::Utils::String.titleize('HanamiUtils')).to eq('Hanami Utils')
      expect(Hanami::Utils::String.titleize('hanami utils')).to eq('Hanami Utils')
      expect(Hanami::Utils::String.titleize('hanami_utils')).to eq('Hanami Utils')
      expect(Hanami::Utils::String.titleize('hanami-utils')).to eq('Hanami Utils')
      expect(Hanami::Utils::String.titleize("hanami' utils")).to eq("Hanami' Utils")
      expect(Hanami::Utils::String.titleize('hanami’ utils')).to eq('Hanami’ Utils')
      expect(Hanami::Utils::String.titleize('hanami` utils')).to eq('Hanami` Utils')
    end
  end

  describe '.capitalize' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.capitalize('hanami')).to be_kind_of(::String)
    end

    it "doesn't mutate self" do
      string = Hanami::Utils::String.new('hanami')
      Hanami::Utils::String.capitalize(string)
      expect(string).to eq('hanami')
    end

    it 'returns an capitalized string' do
      expect(Hanami::Utils::String.capitalize('hanami')).to eq('Hanami')
      expect(Hanami::Utils::String.capitalize('HanamiUtils')).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize('hanami utils')).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize('hanami_utils')).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize('hanami-utils')).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize("hanami' utils")).to eq("Hanami' utils")
      expect(Hanami::Utils::String.capitalize('hanami’ utils')).to eq('Hanami’ utils')
      expect(Hanami::Utils::String.capitalize('hanami` utils')).to eq('Hanami` utils')
      expect(Hanami::Utils::String.capitalize('OneTwoThree')).to eq('One two three')
      expect(Hanami::Utils::String.capitalize('one Two three')).to eq('One two three')
      expect(Hanami::Utils::String.capitalize('one_two_three')).to eq('One two three')
      expect(Hanami::Utils::String.capitalize('one-two-three')).to eq('One two three')

      expect(Hanami::Utils::String.capitalize(:HanamiUtils)).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize(:'hanami utils')).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize(:hanami_utils)).to eq('Hanami utils')
      expect(Hanami::Utils::String.capitalize(:'hanami-utils')).to eq('Hanami utils')
    end
  end

  describe '.classify' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.classify('hanami')).to be_kind_of(::String)
    end

    it 'returns a classified string' do
      expect(Hanami::Utils::String.classify('hanami')).to eq('Hanami')
      expect(Hanami::Utils::String.classify('hanami_router')).to eq('HanamiRouter')
      expect(Hanami::Utils::String.classify('hanami-router')).to eq('HanamiRouter')
      expect(Hanami::Utils::String.classify('hanami/router')).to eq('Hanami::Router')
      expect(Hanami::Utils::String.classify('hanami::router')).to eq('Hanami::Router')
      expect(Hanami::Utils::String.classify('hanami::router/base_object')).to eq('Hanami::Router::BaseObject')
      expect(Hanami::Utils::String.classify('AwesomeProject')).to eq('AwesomeProject')
      expect(Hanami::Utils::String.classify('AwesomeProject::Namespace')).to eq('AwesomeProject::Namespace')
    end

    it 'returns a classified string from symbol' do
      expect(Hanami::Utils::String.classify(:hanami)).to eq('Hanami')
      expect(Hanami::Utils::String.classify(:hanami_router)).to eq('HanamiRouter')
      expect(Hanami::Utils::String.classify(:'hanami-router')).to eq('HanamiRouter')
      expect(Hanami::Utils::String.classify(:'hanami/router')).to eq('Hanami::Router')
      expect(Hanami::Utils::String.classify(:'hanami::router')).to eq('Hanami::Router')
    end
  end

  describe '.underscore' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.underscore('Hanami')).to be_kind_of(::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      Hanami::Utils::String.underscore(string)
      expect(string).to eq('Hanami')
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.underscore('Hanami')
      expect(string).to eq('hanami')
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.underscore('HanamiView')
      expect(string).to eq('hanami_view')
    end

    it 'substitutes double colons with path separators' do
      string = Hanami::Utils::String.underscore('Hanami::Utils::String')
      expect(string).to eq('hanami/utils/string')
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.underscore('APIDoc')
      expect(string).to eq('api_doc')
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.underscore('Lucky23Action')
      expect(string).to eq('lucky23_action')
    end

    it 'handles dashes' do
      string = Hanami::Utils::String.underscore('hanami-utils')
      expect(string).to eq('hanami_utils')
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.underscore('Hanami Utils')
      expect(string).to eq('hanami_utils')
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.underscore('è vero')
      expect(string).to eq('è_vero')
    end
  end

  describe '.dasherize' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.dasherize('Hanami')).to be_kind_of(::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      Hanami::Utils::String.dasherize(string)
      expect(string).to eq('Hanami')
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.new('Hanami')
      expect(Hanami::Utils::String.dasherize(string)).to eq('hanami')
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.new('HanamiView')
      expect(Hanami::Utils::String.dasherize(string)).to eq('hanami-view')
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.new('APIDoc')
      expect(Hanami::Utils::String.dasherize(string)).to eq('api-doc')
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.dasherize('Lucky23Action')
      expect(string).to eq('lucky23-action')
    end

    it 'handles underscores' do
      string = Hanami::Utils::String.dasherize('hanami_utils')
      expect(string).to eq('hanami-utils')
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.dasherize('Hanami Utils')
      expect(string).to eq('hanami-utils')
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.dasherize('è vero')
      expect(string).to eq('è-vero')
    end
  end

  describe '.demodulize' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.demodulize('Hanami')).to be_kind_of(::String)
    end

    it 'returns the class name without the namespace' do
      expect(Hanami::Utils::String.demodulize('String')).to eq('String')
      expect(Hanami::Utils::String.demodulize('Hanami::Utils::String')).to eq('String')
    end
  end

  describe '.namespace' do
    it 'returns an instance of ::String' do
      expect(Hanami::Utils::String.namespace('Hanami')).to be_kind_of(::String)
    end

    it 'returns the top level module name' do
      expect(Hanami::Utils::String.namespace('String')).to eq('String')
      expect(Hanami::Utils::String.namespace('Hanami::Utils::String')).to eq('Hanami')
    end
  end

  describe '.pluralize' do
    before do
      @singular, @plural = *TEST_PLURALS.to_a.sample
    end

    it 'returns a String instance' do
      result = Hanami::Utils::String.pluralize(@singular)
      expect(result).to be_kind_of(::String)
    end

    it 'pluralizes string' do
      result = Hanami::Utils::String.pluralize(@singular)
      expect(result).to eq(@plural)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@singular)
      plural_string = Hanami::Utils::String.pluralize(string)

      expect(string).to eq(@singular)
      expect(plural_string).to eq(@plural)
    end
  end

  describe '.singularize' do
    before do
      @singular, @plural = *TEST_SINGULARS.to_a.sample
    end

    it '::String instance' do
      result = Hanami::Utils::String.singularize(@plural)
      expect(result).to be_kind_of(::String)
    end

    it 'singularizes string' do
      result = Hanami::Utils::String.singularize(@plural)
      expect(result).to eq(@singular)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@plural)
      singular_string = Hanami::Utils::String.singularize(string)

      expect(singular_string).to eq(@singular)
      expect(string).to eq(@plural)
    end
  end

  describe '.rsub' do
    it '::String instance' do
      result = Hanami::Utils::String.rsub('authors/books/index', //, '')
      expect(result).to be_kind_of(::String)
    end

    it 'does not mutate original string' do
      string = Hanami::Utils::String.new('authors/books/index')
      Hanami::Utils::String.rsub(string, %r{/}, '#')

      expect(string).to eq('authors/books/index')
    end

    it 'replaces rightmost instance (regexp)' do
      result = Hanami::Utils::String.rsub('authors/books/index', %r{/}, '#')
      expect(result).to eq('authors/books#index')
    end

    it 'replaces rightmost instance (string)' do
      result = Hanami::Utils::String.rsub('authors/books/index', '/', '#')
      expect(result).to eq('authors/books#index')
    end

    it 'accepts Hanami::Utils::String as replacement' do
      replacement = Hanami::Utils::String.new('#')
      result      = Hanami::Utils::String.rsub('authors/books/index', %r{/}, replacement)

      expect(result).to eq('authors/books#index')
    end

    it 'returns the initial string no match' do
      result = Hanami::Utils::String.rsub('index', %r{/}, '#')
      expect(result).to eq('index')
    end
  end

  describe '#titleize' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('hanami').titleize).to be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate self' do
      string = Hanami::Utils::String.new('hanami')
      string.titleize
      expect(string).to eq('hanami')
    end

    it 'returns an titleized string' do
      expect(Hanami::Utils::String.new('hanami').titleize).to eq('Hanami')
      expect(Hanami::Utils::String.new('HanamiUtils').titleize).to eq('Hanami Utils')
      expect(Hanami::Utils::String.new('hanami utils').titleize).to eq('Hanami Utils')
      expect(Hanami::Utils::String.new('hanami_utils').titleize).to eq('Hanami Utils')
      expect(Hanami::Utils::String.new('hanami-utils').titleize).to eq('Hanami Utils')
      expect(Hanami::Utils::String.new("hanami' utils").titleize).to eq("Hanami' Utils")
      expect(Hanami::Utils::String.new('hanami’ utils').titleize).to eq('Hanami’ Utils')
      expect(Hanami::Utils::String.new('hanami` utils').titleize).to eq('Hanami` Utils')
    end
  end

  describe '#capitalize' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('hanami').capitalize).to be_kind_of(Hanami::Utils::String)
    end

    it "doesn't mutate self" do
      string = Hanami::Utils::String.new('hanami')
      string.capitalize
      expect(string).to eq('hanami')
    end

    it 'returns an capitalized string' do
      expect(Hanami::Utils::String.new('hanami').capitalize).to eq('Hanami')
      expect(Hanami::Utils::String.new('HanamiUtils').capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new('hanami utils').capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new('hanami_utils').capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new('hanami-utils').capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new("hanami' utils").capitalize).to eq("Hanami' utils")
      expect(Hanami::Utils::String.new('hanami’ utils').capitalize).to eq('Hanami’ utils')
      expect(Hanami::Utils::String.new('hanami` utils').capitalize).to eq('Hanami` utils')
      expect(Hanami::Utils::String.new('OneTwoThree').capitalize).to eq('One two three')
      expect(Hanami::Utils::String.new('one Two three').capitalize).to eq('One two three')
      expect(Hanami::Utils::String.new('one_two_three').capitalize).to eq('One two three')
      expect(Hanami::Utils::String.new('one-two-three').capitalize).to eq('One two three')

      expect(Hanami::Utils::String.new(:HanamiUtils).capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new(:'hanami utils').capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new(:hanami_utils).capitalize).to eq('Hanami utils')
      expect(Hanami::Utils::String.new(:'hanami-utils').capitalize).to eq('Hanami utils')
    end
  end

  describe '#classify' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('hanami').classify).to be_kind_of(Hanami::Utils::String)
    end

    it 'returns a classified string' do
      expect(Hanami::Utils::String.new('hanami').classify).to eq('Hanami')
      expect(Hanami::Utils::String.new('hanami_router').classify).to eq('HanamiRouter')
      expect(Hanami::Utils::String.new('hanami-router').classify).to eq('HanamiRouter')
      expect(Hanami::Utils::String.new('hanami/router').classify).to eq('Hanami::Router')
      expect(Hanami::Utils::String.new('hanami::router').classify).to eq('Hanami::Router')
      expect(Hanami::Utils::String.new('hanami::router/base_object').classify).to eq('Hanami::Router::BaseObject')
      expect(Hanami::Utils::String.new('AwesomeProject').classify).to eq('AwesomeProject')
      expect(Hanami::Utils::String.new('AwesomeProject::Namespace').classify).to eq('AwesomeProject::Namespace')
    end

    it 'returns a classified string from symbol' do
      expect(Hanami::Utils::String.new(:hanami).classify).to eq('Hanami')
      expect(Hanami::Utils::String.new(:hanami_router).classify).to eq('HanamiRouter')
      expect(Hanami::Utils::String.new(:'hanami-router').classify).to eq('HanamiRouter')
      expect(Hanami::Utils::String.new(:'hanami/router').classify).to eq('Hanami::Router')
      expect(Hanami::Utils::String.new(:'hanami::router').classify).to eq('Hanami::Router')
    end
  end

  describe '#underscore' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('Hanami').underscore).to be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      string.underscore
      expect(string).to eq('Hanami')
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.new('Hanami')
      expect(string.underscore).to eq('hanami')
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.new('HanamiView')
      expect(string.underscore).to eq('hanami_view')
    end

    it 'substitutes double colons with path separators' do
      string = Hanami::Utils::String.new('Hanami::Utils::String')
      expect(string.underscore).to eq('hanami/utils/string')
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.new('APIDoc')
      expect(string.underscore).to eq('api_doc')
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.new('Lucky23Action')
      expect(string.underscore).to eq('lucky23_action')
    end

    it 'handles dashes' do
      string = Hanami::Utils::String.new('hanami-utils')
      expect(string.underscore).to eq('hanami_utils')
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.new('Hanami Utils')
      expect(string.underscore).to eq('hanami_utils')
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.new('è vero')
      expect(string.underscore).to eq('è_vero')
    end
  end

  describe '#dasherize' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('Hanami').dasherize).to be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate itself' do
      string = Hanami::Utils::String.new('Hanami')
      string.dasherize
      expect(string).to eq('Hanami')
    end

    it 'removes all the upcase characters' do
      string = Hanami::Utils::String.new('Hanami')
      expect(string.dasherize).to eq('hanami')
    end

    it 'transforms camel case class names' do
      string = Hanami::Utils::String.new('HanamiView')
      expect(string.dasherize).to eq('hanami-view')
    end

    it 'handles acronyms' do
      string = Hanami::Utils::String.new('APIDoc')
      expect(string.dasherize).to eq('api-doc')
    end

    it 'handles numbers' do
      string = Hanami::Utils::String.new('Lucky23Action')
      expect(string.dasherize).to eq('lucky23-action')
    end

    it 'handles underscores' do
      string = Hanami::Utils::String.new('hanami_utils')
      expect(string.dasherize).to eq('hanami-utils')
    end

    it 'handles spaces' do
      string = Hanami::Utils::String.new('Hanami Utils')
      expect(string.dasherize).to eq('hanami-utils')
    end

    it 'handles accented letters' do
      string = Hanami::Utils::String.new('è vero')
      expect(string.dasherize).to eq('è-vero')
    end
  end

  describe '#demodulize' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('Hanami').demodulize).to be_kind_of(Hanami::Utils::String)
    end

    it 'returns the class name without the namespace' do
      expect(Hanami::Utils::String.new('String').demodulize).to eq('String')
      expect(Hanami::Utils::String.new('Hanami::Utils::String').demodulize).to eq('String')
    end
  end

  describe '#namespace' do
    it 'returns an instance of Hanami::Utils::String' do
      expect(Hanami::Utils::String.new('Hanami').namespace).to be_kind_of(Hanami::Utils::String)
    end

    it 'returns the top level module name' do
      expect(Hanami::Utils::String.new('String').namespace).to eq('String')
      expect(Hanami::Utils::String.new('Hanami::Utils::String').namespace).to eq('Hanami')
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

      expect(@logger).to all(be_kind_of(Hanami::Utils::String))
    end

    it 'calls the given block for each token occurrence' do
      string = Hanami::Utils::String.new('Hanami::(Utils|App)')
      string.tokenize do |token|
        @logger.push token
      end

      expect(@logger).to eq(['Hanami::Utils', 'Hanami::App'])
    end

    it 'guarantees the block to be called even when the token conditions are not met' do
      string = Hanami::Utils::String.new('Hanami')
      string.tokenize do |token|
        @logger.push token
      end

      expect(@logger).to eq(['Hanami'])
    end

    it 'returns nil' do
      result = Hanami::Utils::String.new('Hanami::(Utils|App)').tokenize {}
      expect(result).to be_nil
    end
  end

  describe '#pluralize' do
    before do
      @singular, @plural = *TEST_PLURALS.to_a.sample
    end

    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new(@singular).pluralize
      expect(result).to be_kind_of(Hanami::Utils::String)
    end

    it 'pluralizes string' do
      result = Hanami::Utils::String.new(@singular).pluralize
      expect(result).to eq(@plural)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@singular)

      expect(string.pluralize).to eq(@plural)
      expect(string).to eq(@singular)
    end
  end

  describe '#singularize' do
    before do
      @singular, @plural = *TEST_SINGULARS.to_a.sample
    end

    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new(@plural).singularize
      expect(result).to be_kind_of(Hanami::Utils::String)
    end

    it 'singularizes string' do
      result = Hanami::Utils::String.new(@plural).singularize
      expect(result).to eq(@singular)
    end

    it 'does not modify the original string' do
      string = Hanami::Utils::String.new(@plural)

      expect(string.singularize).to eq(@singular)
      expect(string).to eq(@plural)
    end
  end

  describe '#rsub' do
    it 'returns a Hanami::Utils::String instance' do
      result = Hanami::Utils::String.new('authors/books/index').rsub(//, '')
      expect(result).to be_kind_of(Hanami::Utils::String)
    end

    it 'does not mutate original string' do
      string = Hanami::Utils::String.new('authors/books/index')
      string.rsub(%r{/}, '#')

      expect(string).to eq('authors/books/index')
    end

    it 'replaces rightmost instance (regexp)' do
      result = Hanami::Utils::String.new('authors/books/index').rsub(%r{/}, '#')
      expect(result).to eq('authors/books#index')
    end

    it 'replaces rightmost instance (string)' do
      result = Hanami::Utils::String.new('authors/books/index').rsub('/', '#')
      expect(result).to eq('authors/books#index')
    end

    it 'accepts Hanami::Utils::String as replacement' do
      replacement = Hanami::Utils::String.new('#')
      result      = Hanami::Utils::String.new('authors/books/index').rsub(%r{/}, replacement)

      expect(result).to eq('authors/books#index')
    end

    it 'returns the initial string no match' do
      result = Hanami::Utils::String.new('index').rsub(%r{/}, '#')
      expect(result).to eq('index')
    end
  end

  describe 'string interface' do
    it 'responds to ::String methods and returns a new Hanami::Utils::String' do
      string = Hanami::Utils::String.new("Hanami\n").chomp
      expect(string).to eq('Hanami')
      expect(string).to be_kind_of Hanami::Utils::String
    end

    it 'responds to ::String methods and only returns a new Hanami::Utils::String when the return value is a string' do
      string = Hanami::Utils::String.new('abcdef')
      expect(string.casecmp('abcde')).to eq(1)
    end

    it 'responds to whatever ::String responds to' do
      string = Hanami::Utils::String.new('abcdef')

      expect(string).to respond_to :reverse
      expect(string).not_to respond_to :unknown_method
    end

    describe 'equality' do
      it 'has a working equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')

        expect(string.==(other)).to be_truthy
      end

      it 'has a working equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        expect(string.==('hanami')).to be_truthy
      end
    end

    describe 'case equality' do
      it 'has a working case equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')
        expect(string.===(other)).to be_truthy # rubocop:disable Style/CaseEquality
      end

      it 'has a working case equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        expect(string.===('hanami')).to be_truthy # rubocop:disable Style/CaseEquality
      end
    end

    describe 'value equality' do
      it 'has a working value equality' do
        string = Hanami::Utils::String.new('hanami')
        other  = Hanami::Utils::String.new('hanami')
        expect(string).to eql(other)
      end

      it 'has a working value equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        expect(string).to eql('hanami')
      end
    end

    describe 'identity equality' do
      it 'has a working identity equality' do
        string = Hanami::Utils::String.new('hanami')
        expect(string).to equal(string)
      end

      it 'has a working identity equality with raw strings' do
        string = Hanami::Utils::String.new('hanami')
        expect(string).not_to equal('hanami')
      end
    end

    describe '#hash' do
      it 'returns the same hash result of ::String' do
        expected = 'hello'.hash
        actual   = Hanami::Utils::String.new('hello').hash

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'unknown method' do
    it 'raises error' do
      expect { Hanami::Utils::String.new('one').yay! }
        .to raise_error(NoMethodError, %(undefined method `yay!' for "one":Hanami::Utils::String))
    end

    # See: https://github.com/hanami/utils/issues/48
    it 'returns the correct object when a NoMethodError is raised' do
      string            = Hanami::Utils::String.new('/path/to/something')
      exception_message = %(undefined method `boom' for "/":String)

      expect { string.gsub(%r{/}, &:boom) }
        .to raise_error(NoMethodError, exception_message)
    end
  end
end
