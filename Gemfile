# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_importable.gemspec
gemspec
group :test do
  gem 'sprockets-rails', '2.3.3'
  gem 'rails', '4.2.0'
  gem 'rspec-rails'
  gem 'activeadmin',
      github: 'activeadmin',
      ref: 'd787029e5523be2eb2ed99816eb0cecca2b72862'
  gem 'coveralls', require: false # Test coverage website. Go to https://coveralls.io
  gem 'sass-rails'
  gem 'sqlite3'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'mime-types', (RUBY_VERSION >= '2.0' ? '~> 3.0' : '~> 2.99')
end
