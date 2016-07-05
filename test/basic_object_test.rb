require 'test_helper'
require 'hanami/utils/basic_object'

class TestClass < Hanami::Utils::BasicObject
end

describe Hanami::Utils::BasicObject do
  describe '#respond_to_missing?' do
    it 'raises an exception if respond_to? method is not implemented' do
      lambda do
        TestClass.new.respond_to?(:no_existing_method)
      end.must_raise(NotImplementedError)
    end

    it 'returns true given respond_to? method was implemented' do
      TestCase = Class.new(TestClass) do
        def respond_to?(_method_name, _include_all = false)
          true
        end
      end

      assert TestCase.new.respond_to?(:no_existing_method)
    end
  end
end
