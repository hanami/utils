source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'debugger',  require: false, platforms: :ruby if RUBY_VERSION == '2.0.0'
  gem 'yard',      require: false
end

gem 'simplecov', require: false
gem 'coveralls', require: false
