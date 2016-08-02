source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_importable.gemspec
gemspec
group :test do
  default_rails_version = '4.2.6'
  # gem 'sprockets-rails', '2.3.3'
  gem 'rails',  "#{ENV['RAILS'] || default_rails_version}"
  gem 'rspec-rails'
  gem 'activeadmin', '1.0.0.pre4'
  gem 'coveralls', require: false # Test coverage website. Go to https://coveralls.io
  gem 'sass-rails'
  gem 'sqlite3'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'json', '< 2.0', platforms: :ruby_19 # Json 2.0 requires Ruby >= 2.0
  gem 'mime-types', '< 3.0.0', platforms: [:ruby_19, :ruby_20]
  gem 'tins', '< 1.3.4', platforms: :ruby_19
end
