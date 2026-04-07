desc "Creates a test rails app for the specs to run against"
task :setup do
  require 'rails/version'

  rails_new_opts = %w(
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    -m
    spec/support/rails_template.rb
  )
  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING} #{rails_new_opts.join(' ')}"
end
