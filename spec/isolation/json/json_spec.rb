require_relative '../../support/isolation_spec_helper'
require 'hanami/utils/json'

RSpec.describe Hanami::Utils::Json do
  describe 'with JSON' do
    it 'uses JSON engine' do
      expect(Hanami::Utils::Json.class_variable_get(:@@engine)).to eq(JSON)
    end

    describe '.parse' do
      it 'loads given payload' do
        actual = Hanami::Utils::Json.parse %({"a":1})
        expect(actual).to eq('a' => 1)
      end

      it 'raises error if given payload is malformed' do
        expect { Hanami::Utils::Json.parse %({"a:1}) }.to raise_error(Hanami::Utils::Json::ParserError)
      end

      # See: https://github.com/hanami/utils/issues/169
      it "doesn't eval payload" do
        actual = Hanami::Utils::Json.parse %({"json_class": "Foo"})
        expect(actual).to eq('json_class' => 'Foo')
      end
    end
  end
end

RSpec::Support::Runner.run
