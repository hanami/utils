require 'hanami/utils/basic_object'
require 'pp'

class TestClass < Hanami::Utils::BasicObject
end

RSpec.describe Hanami::Utils::BasicObject do
  describe '#respond_to_missing?' do
    it 'raises an exception if respond_to? method is not implemented' do
      expect { TestClass.new.respond_to?(:no_existing_method) }
        .to raise_error(NotImplementedError)
    end

    it 'returns true given respond_to? method was implemented' do
      TestCase = Class.new(TestClass) do
        def respond_to?(_method_name, _include_all = false)
          true
        end
      end

      expect(TestCase.new).to respond_to(:no_existing_method)
    end
  end

  describe '#class' do
    it 'returns TestClass' do
      expect(TestClass.new.class).to eq TestClass
    end
  end

  describe '#inspect' do
    it 'returns the inspect message' do
      inspect_msg = TestClass.new.inspect
      expect(inspect_msg).to match(/\A#<TestClass:\w+>\z/)
    end
  end

  # See https://github.com/hanami/hanami/issues/629
  it 'is pretty printable' do
    pp TestClass.new
  end
end
