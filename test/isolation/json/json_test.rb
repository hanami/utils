require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'minitest'
require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require 'json'
require 'hanami/utils/json'

describe Hanami::Utils::Json do
  describe 'with JSON' do
    it 'uses JSON engine' do
      Hanami::Utils::Json.class_variable_get(:@@engine).must_equal(JSON)
    end

    describe '.parse' do
      it 'loads given payload' do
        actual = Hanami::Utils::Json.parse %({"a":1})
        actual.must_equal('a' => 1)
      end

      it 'raises error if given payload is malformed' do
        -> { Hanami::Utils::Json.parse %({"a:1}) }.must_raise(Hanami::Utils::Json::ParserError)
      end

      # See: https://github.com/hanami/utils/issues/169
      it "doesn't eval payload" do
        actual = Hanami::Utils::Json.parse %({"json_class": "Foo"})
        actual.must_equal('json_class' => 'Foo')
      end
    end
  end
end
