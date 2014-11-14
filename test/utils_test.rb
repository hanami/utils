require 'test_helper'
require 'lotus/utils'

describe Lotus::Utils do
  describe '.jruby?' do
    it 'introspects the current platform' do
      if RUBY_PLATFORM == 'java'
        assert Lotus::Utils.jruby?,  'expected JRuby platform'
      else
        assert !Lotus::Utils.jruby?, 'expected non JRuby platform'
      end
    end
  end

  describe '.rubinius?' do
    it 'introspects the current platform' do
      if RUBY_ENGINE == 'rbx'
        assert Lotus::Utils.rubinius?,  'expected Rubinius platform'
      else
        assert !Lotus::Utils.rubinius?, 'expected non Rubinius platform'
      end
    end
  end
end
