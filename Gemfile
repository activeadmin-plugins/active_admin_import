source 'https://rubygems.org'
gemspec

default_rails_version = '7.1.0'
default_activeadmin_version = '3.2.0'

gem 'rails', "~> #{ENV['RAILS'] || default_rails_version}"
gem 'activeadmin', "~> #{ENV['AA'] || default_activeadmin_version}"
gem 'sprockets-rails'
gem 'sass-rails'

group :test do
  gem 'simplecov', require: false
  gem 'rspec-rails'
  case ENV['DB']
  when 'mysql'
    gem 'mysql2'
  when 'postgres', 'postgresql'
    gem 'pg'
  else
    gem 'sqlite3', '~> 2.0'
  end
  gem 'database_cleaner'
  gem 'capybara'
  gem 'cuprite'
  gem 'webrick', require: false
end
