source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_importable.gemspec
gemspec
default_rails_version = '4.2.6'
rails_version = ENV['RAILS'] || default_rails_version
rails_major = rails_version[0]

group :test do

  gem 'rails', rails_version
  if rails_major == '5'
    gem 'inherited_resources', github: 'activeadmin/inherited_resources'
    gem 'activeadmin', github: 'activeadmin/activeadmin'
  else
    gem 'activeadmin', '1.0.0.pre4'
  end

  gem 'rspec-rails'
  gem 'coveralls', require: false # Test coverage website. Go to https://coveralls.io
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
