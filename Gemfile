source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.2.0'
  gem 'yard',   require: false
end

gem 'multi_json', '~> 1.0',  require: false
gem 'rubocop',    '~> 0.41', require: false
gem 'coveralls',             require: false
