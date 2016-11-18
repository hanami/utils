require 'rubygems'
require 'bundler'
Bundler.require(:default, :multi_json)

require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require 'hanami/utils'
require 'gson' if Hanami::Utils.jruby?
require 'hanami/utils/json'

describe Hanami::Utils::Json do
  describe 'with MultiJson' do
    it 'uses MultiJson engine' do
      Hanami::Utils::Json.class_variable_get(:@@engine).must_be_kind_of(Hanami::Utils::Json::MultiJsonAdapter)
    end

    describe '.load' do
      it 'loads given payload' do
        capture_io do
          actual = Hanami::Utils::Json.load %({"a":1})
          actual.must_equal('a' => 1)
        end
      end

      it 'raises error if given payload is malformed' do
        capture_io do
          -> { Hanami::Utils::Json.load %({"a:1}) }.must_raise(Hanami::Utils::Json::ParserError)
        end
      end

      it 'is deprecated' do
        _, err = capture_io do
          Hanami::Utils::Json.load %({"a":1})
        end

        err.must_include "`Hanami::Utils::Json.load' is deprecated, please use `Hanami::Utils::Json.parse'"
      end
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

    describe '.dump' do
      it 'dumps given Hash' do
        capture_io do
          actual = Hanami::Utils::Json.dump(a: 1)
          actual.must_equal %({"a":1})
        end
      end

      it 'is deprecated' do
        _, err = capture_io do
          Hanami::Utils::Json.dump(a: 1)
        end

        err.must_include "`Hanami::Utils::Json.dump' is deprecated, please use `Hanami::Utils::Json.generate'"
      end
    end

    describe '.generate' do
      it 'dumps given Hash' do
        actual = Hanami::Utils::Json.generate(a: 1)
        actual.must_equal %({"a":1})
      end
    end
  end
end
