require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'minitest'
require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'

describe 'Hanami::Events' do
  describe 'without concurrent-ruby' do
    it 'raises error' do
      exception = lambda do
        require 'hanami/events'
      end.must_raise(RuntimeError)

      exception.message.must_equal "Cannot find `concurrent-ruby' gem, please install it and retry."
    end
  end
end
