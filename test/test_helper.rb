require 'rubygems'
require 'bundler/setup'
require 'time'

if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

TEST_ENCODINGS = Encoding.name_list.each_with_object(['UTF-8']) do |encoding, result|
  test_string = '<script>'.encode(Encoding::UTF_8)

  string = begin
             test_string.encode(encoding)
           rescue
             nil
           end

  result << encoding if !string.nil? && string != test_string
end

def stub_stdout_constant # rubocop:disable Metrics/MethodLength
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
  Time.stub :now, Time.parse("2017-01-15 16:00:23 +0100") do
    yield
  end
end

require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require_relative './fixtures'
