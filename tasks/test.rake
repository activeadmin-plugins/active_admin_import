desc "Creates a test rails app for the specs to run against"
task :setup do
  require 'rails/version'

  db = ENV['DB'] || 'sqlite'
  rails_db = case db
             when 'mysql' then 'mysql'
             when 'postgres', 'postgresql' then 'postgresql'
             else 'sqlite3'
             end

  rails_new_opts = %W(
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    -d #{rails_db}
    -m
    spec/support/rails_template.rb
  )
  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING}-#{db} #{rails_new_opts.join(' ')}"
end
