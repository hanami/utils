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

def with_captured_stdout
  original = $stdout
  captured = StringIO.new
  $stdout  = captured
  yield
  $stdout.string
ensure
  $stdout = original
end

def stub_time_now
  Time.stub :now, Time.parse("2017-01-15 16:00:23 +0100") do
    yield
  end
end

require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require_relative './fixtures'
