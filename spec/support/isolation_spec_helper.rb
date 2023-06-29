# frozen_string_literal: true

require "rubygems"
require "bundler"
Bundler.setup(:default, :development, :test)

ENV["SIMPLECOV_COMMAND_NAME"] = "Isolation Tests PID #{$$}"

$LOAD_PATH.unshift "lib"
require "hanami/utils"
require_relative "rspec"
require_relative "coverage"

module RSpec
  module Support
    module Runner
      def self.run
        Core::Runner.autorun
      end
    end
  end
end
