require 'rspec/expectations'

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    File.read(actual) == expected
  end

  failure_message do |actual|
    "expected that `#{actual}' would have content '#{expected}', but it has '#{File.read(actual)}'"
  end
end
