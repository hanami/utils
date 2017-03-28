source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.2.0'
  gem 'yard',   require: false
end

group :multi_json do
  gem 'multi_json', '~> 1.0', require: false
end

gem 'minitest', '~> 5.9'
gem 'gson',     '>= 0.6',  require: false, platforms: :jruby
gem 'rubocop',  '~> 0.41', require: false
gem 'coveralls',           require: false
