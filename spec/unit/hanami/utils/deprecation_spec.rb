# frozen_string_literal: true

require "hanami/utils/deprecation"

class DeprecationTest
  def old_method
    Hanami::Utils::Deprecation.new("old_method is deprecated, please use new_method")
    new_method
  end

  def new_method
  end
end

class DeprecationWrapperTest
  def initialize
    @engine = DeprecationTest.new
  end

  def run
    @engine.old_method
  end
end

RSpec.describe Hanami::Utils::Deprecation do
  it "prints a deprecation warning for direct call" do
    stack = if Hanami::Utils.jruby?
              "#{__FILE__}:33:in `block in (root)'"
            else
              "#{__FILE__}:33:in `block (3 levels) in <top (required)>'"
            end

    expect { DeprecationTest.new.old_method }
      .to output(include("old_method is deprecated, please use new_method - called from: #{stack}.")).to_stderr
  end

  it "prints a deprecation warning for nested call" do
    expect { DeprecationWrapperTest.new.run }
      .to output(include("old_method is deprecated, please use new_method - called from: #{__FILE__}:21:in `run'.")).to_stderr
  end
end
