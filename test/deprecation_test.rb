require 'test_helper'
require 'lotus/utils/deprecation'

class DeprecationTest
  def old_method
    Lotus::Utils::Deprecation.new('old_method is deprecated, please use new_method')
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

describe Lotus::Utils::Deprecation do
  it 'prints a deprecation warning for direct call' do
    _, err = capture_io do
      DeprecationTest.new.old_method
    end

    stack = $0 == __FILE__ ? "#{ __FILE__ }:27:in `block (3 levels) in <main>'" :
      "#{ __FILE__ }:27:in `block (3 levels) in <top (required)>'"

    err.chomp.must_equal "old_method is deprecated, please use new_method - called from: #{ stack }."
  end

  it 'prints a deprecation warning for nested call' do
    _, err = capture_io do
      DeprecationWrapperTest.new.run
    end

    err.chomp.must_equal "old_method is deprecated, please use new_method - called from: #{ __FILE__ }:20:in `run'."
  end
end
