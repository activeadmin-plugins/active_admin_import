source 'https://rubygems.org'
gemspec

default_rails_version = '7.1.0'
default_activeadmin_version = '3.2.0'

rails_version = ENV['RAILS'] || default_rails_version
gem 'rails', "~> #{rails_version}"
gem 'activeadmin', "~> #{ENV['AA'] || default_activeadmin_version}"

if Gem::Version.new(rails_version) >= Gem::Version.new('8.0.0')
  gem 'propshaft'
else
  gem 'sprockets-rails'
  gem 'sass-rails'
end

group :test do
  gem 'simplecov', require: false
  gem 'rspec-rails'
  gem 'sqlite3', '~> 2.0'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'cuprite'
  gem 'webrick', require: false
end
