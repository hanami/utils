# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri if RUBY_VERSION >= "2.2.0"
  gem "yard",   require: false
end

group :multi_json do
  gem "multi_json", "~> 1.0", require: false
end

group :inflecto do
  gem "inflecto", "~> 0.0.2", require: false
end

gem "gson", ">= 0.6", require: false, platforms: :jruby

gem "rubocop", "~> 0.61.1", require: false
gem "codecov", require: false, group: :test
