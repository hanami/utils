require 'test_helper'
require 'hanami/utils/json'
require 'json'
require 'hanami/utils/io'

describe Hanami::Utils::Json do
  after do
    Hanami::Utils::IO.silence_warnings do
      Hanami::Utils::Json.class_variable_set(:@@engine, MultiJson)
      Hanami::Utils::Json::ParserError = MultiJson::ParseError
    end
  end

  describe '.load' do
    describe 'with JSON' do
      before do
        Hanami::Utils::IO.silence_warnings do
          Hanami::Utils::Json.class_variable_set(:@@engine, JSON)
          Hanami::Utils::Json::ParserError = ::JSON::ParserError
        end
      end

      it 'loads given payload' do
        actual = Hanami::Utils::Json.load %({"a":1})
        actual.must_equal('a' => 1)
      end

      it 'raises error if given payload is malformed' do
        -> { Hanami::Utils::Json.load %({"a:1}) }.must_raise(Hanami::Utils::Json::ParserError)
      end
    end

    describe 'with MultiJson' do
      before do
        Hanami::Utils::IO.silence_warnings do
          Hanami::Utils::Json.class_variable_set(:@@engine, MultiJson)
          Hanami::Utils::Json::ParserError = MultiJson::ParseError
        end
      end

      it 'loads given payload' do
        actual = Hanami::Utils::Json.load %({"a":1})
        actual.must_equal('a' => 1)
      end

      it 'raises error if given payload is malformed' do
        -> { Hanami::Utils::Json.load %({"a:1}) }.must_raise(Hanami::Utils::Json::ParserError)
      end
    end
  end

  describe '.dump' do
    describe 'with JSON' do
      before do
        Hanami::Utils::IO.silence_warnings do
          Hanami::Utils::Json.class_variable_set(:@@engine, JSON)
          Hanami::Utils::Json::ParserError = ::JSON::ParserError
        end
      end

      it 'dumps given Hash' do
        actual = Hanami::Utils::Json.dump(a: 1)
        actual.must_equal %({"a":1})
      end
    end

    describe 'with MultiJson' do
      before do
        Hanami::Utils::IO.silence_warnings do
          Hanami::Utils::Json.class_variable_set(:@@engine, MultiJson)
          Hanami::Utils::Json::ParserError = MultiJson::ParseError
        end
      end

      it 'dumps given Hash' do
        actual = Hanami::Utils::Json.dump(a: 1)
        actual.must_equal %({"a":1})
      end
    end
  end
end
