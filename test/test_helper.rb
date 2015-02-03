require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'
    add_filter   'test'
  end
end

TEST_ENCODINGS = Encoding.name_list.each_with_object(['UTF-8']) do |encoding, result|
  test_string = '<script>'.encode(Encoding::UTF_8)

  string = test_string.encode(encoding) rescue nil

  if !string.nil? && string != test_string
    result << encoding
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require_relative './fixtures'
