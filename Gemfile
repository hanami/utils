source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", platforms: :mri
  gem "yard"
  gem "yard-junk"
end

group :multi_json do
  gem "multi_json", "~> 1.0", require: false
end

gem "codecov", group: :test
gem "gson", ">= 0.6", platforms: :jruby
