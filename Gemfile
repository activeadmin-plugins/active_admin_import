# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_importable.gemspec
gemspec
default_rails_version = '4.2.6'
rails_version = ENV['RAILS'] || default_rails_version
rails_major = rails_version[0]

group :test do
  gem 'rails', rails_version
  gem 'inherited_resources', github: 'activeadmin/inherited_resources' if rails_major == '5'
  gem 'activeadmin', github: 'activeadmin/activeadmin', ref: 'd5638b33841cd6b0987f9086c7cd4e2b10982b88'

  gem 'rspec-rails'
  gem 'coveralls', require: false # Test coverage website. Go to https://coveralls.io
  gem 'sqlite3'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'poltergeist'
  gem 'jquery-ui-rails', '~> 5.0'
end
