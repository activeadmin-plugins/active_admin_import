source 'https://rubygems.org'
gemspec

default_rails_version = '7.1.0'
default_activeadmin_version = '3.2.0'

# `~> 4.0.0.beta22` would admit 4.0.0 GA — pin prereleases exactly so the
# CI cell tests the AA build it claims to test.
aa_version = ENV['AA'] || default_activeadmin_version
aa_op = aa_version.match?(/[a-z]/) ? '=' : '~>'

gem 'rails', "~> #{ENV['RAILS'] || default_rails_version}"
gem 'activeadmin', "#{aa_op} #{aa_version}"

if ENV['AA']&.start_with?('4')
  # AA 4 uses Tailwind + importmap; sass-rails conflicts with Tailwind v4.
  gem 'cssbundling-rails'
  gem 'importmap-rails'
else
  gem 'sprockets-rails'
  gem 'sass-rails'
end

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
end
