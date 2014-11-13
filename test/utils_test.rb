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
end
