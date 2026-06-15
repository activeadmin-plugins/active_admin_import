require_relative '../spec/support/test_app_paths'

desc "Creates a test rails app for the specs to run against"
task :setup do
  require 'rails/version'

  db = ENV['DB'] || 'sqlite'
  rails_db = case db
             when 'mysql' then 'mysql'
             when 'postgres', 'postgresql' then 'postgresql'
             else 'sqlite3'
             end
  aa_v4 = ENV['AA']&.start_with?('4')

  puts "[setup] ActiveAdmin: #{ENV['AA'] || '(Gemfile default)'} / Rails: #{Rails::VERSION::STRING} / DB: #{rails_db}"

  rails_new_opts = %W(
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    -d #{rails_db}
    -m
    spec/support/rails_template.rb
  )
  # v4 drops sprockets-rails (see Gemfile), so skip the asset pipeline to
  # avoid the auto-generated `config/initializers/assets.rb` crashing at boot.
  if aa_v4
    rails_new_opts.unshift('--skip-asset-pipeline')
  else
    # Rails 8.1 wires importmap-rails into the generated ApplicationController
    # (`stale_when_importmap_changes`). The AA 3 app uses Sprockets, not
    # importmap, so that gem is absent and the controller raises NameError at
    # boot. Skip JavaScript so the macro is never generated — the specs run on
    # rack_test and never execute JS anyway.
    rails_new_opts.unshift('--skip-javascript')
  end

  system "bundle exec rails new spec/rails/#{TestAppPaths.app_dir_name} #{rails_new_opts.join(' ')}"
end
