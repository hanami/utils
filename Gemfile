source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.2.0'
  gem 'yard',   require: false
end

group :multi_json do
  gem 'multi_json', '~> 1.0', require: false
end

group :inflecto do
  gem 'inflecto', '~> 0.0.2', require: false
end

gem 'gson', '>= 0.6', require: false, platforms: :jruby

gem 'hanami-devtools', git: 'https://github.com/hanami/devtools.git', require: false
gem 'coveralls', require: false
