require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path('../support', __FILE__)

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
require 'bundler'
Bundler.setup

ENV['RAILS_ENV'] = 'test'
require 'rails'
ENV['RAILS'] = Rails.version
ENV['DB'] ||= 'sqlite'
ENV['RAILS_ROOT'] = File.expand_path("../rails/rails-#{ENV['RAILS']}-#{ENV['DB']}", __FILE__)
system 'rake setup' unless File.exist?(ENV['RAILS_ROOT'])

require 'active_model'
require 'active_record'
require 'action_view'
require 'active_admin'
ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + '/app/admin']
require ENV['RAILS_ROOT'] + '/config/environment.rb'
ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false

require 'rspec/rails'
require 'support/admin'
require 'support/import_form_selectors'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/cuprite'

Capybara.server = :webrick
Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, headless: true, window_size: [1280, 800])
end
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Cuprite races the Tailwind build under AA 4 (no CSS → unstyled DOM →
    # selector failures that look like DOM-ID drift). Rebuild before the
    # suite and abort if nothing landed, so the failure mode is legible.
    if Gem::Version.new(ActiveAdmin::VERSION) >= Gem::Version.new('4')
      rails_root = ENV['RAILS_ROOT']
      ok = system('npm run build:css', chdir: rails_root)
      built = Dir.glob(File.join(rails_root, 'app/assets/builds/*.css'))
                 .find { |p| File.size?(p).to_i.positive? }
      abort "[AA4] Tailwind build produced no CSS in #{rails_root} (npm ok=#{ok})" unless built
    end

    ActiveRecord::Migration.maintain_test_schema!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
