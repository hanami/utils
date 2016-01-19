require 'test_helper'
require 'hanami/utils'

describe Hanami::Utils do
  describe '.jruby?' do
    it 'introspects the current platform' do
      if RUBY_PLATFORM == 'java'
        assert Hanami::Utils.jruby?,  'expected JRuby platform'
      else
        assert !Hanami::Utils.jruby?, 'expected non JRuby platform'
      end
    end
  end

  describe '.rubinius?' do
    it 'introspects the current platform' do
      if RUBY_ENGINE == 'rbx'
        assert Hanami::Utils.rubinius?,  'expected Rubinius platform'
      else
        assert !Hanami::Utils.rubinius?, 'expected non Rubinius platform'
      end
    end
  end
end
