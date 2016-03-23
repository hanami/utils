require 'test_helper'
require 'hanami/utils/basic_object'

class TestClass < Hanami::Utils::BasicObject
end

describe Hanami::Utils::BasicObject do
  describe '#respond_to_missing?' do
    it 'raises an exception if respond_to? method is not implemented' do
      -> {
        TestClass.new.respond_to?(:no_existing_method)
      }.must_raise(NotImplementedError)
    end

    it 'must return true if respond_to? method was implemented' do
      TestCase = Class.new(TestClass) do
        def respond_to?(method_name, include_all = false)
          true
        end
      end

      assert TestCase.new.respond_to?(:no_existing_method)
    end
  end
end
