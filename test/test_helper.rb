require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [
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

def stub_stdout_constant
  begin_block = <<-BLOCK
    original_verbosity = $VERBOSE
    $VERBOSE = nil

    origin_stdout = STDOUT
    STDOUT = StringIO.new
  BLOCK
  TOPLEVEL_BINDING.eval begin_block

  yield
  return_str = STDOUT.string

  ensure_block = <<-BLOCK
    STDOUT = origin_stdout
    $VERBOSE = original_verbosity
  BLOCK
  TOPLEVEL_BINDING.eval ensure_block

  return_str
end

def stub_time_now
  Time.stub :now, Time.utc(1988, 9, 1, 0, 0, 0) do
    yield
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require_relative './fixtures'
