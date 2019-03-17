# frozen_string_literal: true
desc 'Creates a test rails app for the specs to run against'
task :setup do
  require 'rails/version'
  system('mkdir spec/rails') unless File.exist?('spec/rails')
  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING} -m spec/support/rails_template.rb --skip-spring  --skip-turbolinks  --skip-bootsnap"
end
