# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_importable.gemspec
gemspec


group :test do
  default_rails_version = '4.2.8'
  rails_version = ENV['RAILS'] || default_rails_version
  gem 'rails', rails_version
  gem 'rspec-rails'
  gem 'coveralls', require: false # Test coverage website. Go to https://coveralls.io
  gem 'sqlite3'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'poltergeist'
  gem 'jquery-ui-rails', '~> 5.0'
end
