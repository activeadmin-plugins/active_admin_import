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

  if aa_v4
    %w[node npm].each do |bin|
      abort "[setup] AA v4 needs `#{bin}` on PATH for the Tailwind build" unless system("command -v #{bin} > /dev/null 2>&1")
    end
    puts "[setup] node: #{`node --version`.strip} / npm: #{`npm --version`.strip}"
  end

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
  rails_new_opts.unshift('--skip-asset-pipeline') if aa_v4

  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING}-#{db} #{rails_new_opts.join(' ')}"
end
