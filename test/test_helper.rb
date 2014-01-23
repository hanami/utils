$:.unshift 'lib'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Mintest'
  end
end

require 'rubygems'
require 'bundler/setup'
require 'coveralls'
Coveralls.wear!
require 'minitest/autorun'
