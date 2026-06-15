create_file "app/assets/config/manifest.js", skip: true

db = ENV['DB'] || 'sqlite'
case db
when 'mysql'
  remove_file 'config/database.yml'
  create_file 'config/database.yml', <<~YAML
    default: &default
      adapter: mysql2
      encoding: utf8mb4
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      host: <%= ENV.fetch("DB_HOST", "127.0.0.1") %>
      port: <%= ENV.fetch("DB_PORT", 3306) %>
      username: <%= ENV.fetch("DB_USERNAME", "root") %>
      password: <%= ENV.fetch("DB_PASSWORD", "root") %>

    test:
      <<: *default
      database: active_admin_import_test
  YAML
when 'postgres', 'postgresql'
  remove_file 'config/database.yml'
  create_file 'config/database.yml', <<~YAML
    default: &default
      adapter: postgresql
      encoding: unicode
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      host: <%= ENV.fetch("DB_HOST", "127.0.0.1") %>
      port: <%= ENV.fetch("DB_PORT", 5432) %>
      username: <%= ENV.fetch("DB_USERNAME", "postgres") %>
      password: <%= ENV.fetch("DB_PASSWORD", "postgres") %>

    test:
      <<: *default
      database: active_admin_import_test
  YAML
end

generate :model, 'author name:string{10}:uniq last_name:string birthday:date --force'
generate :model, 'post title:string:uniq body:text request_ip:string author:references --force'
generate :model, 'post_comment body:text post:references --force'

inject_into_file 'app/models/author.rb', "  validates_presence_of :name\n  validates_uniqueness_of :last_name\n", before: 'end'
inject_into_file 'app/models/post.rb', "  validates_presence_of :author\n  has_many :post_comments\n", before: 'end'

# Rails 8.1's generated ApplicationController calls `stale_when_importmap_changes`,
# a macro provided by importmap-rails. The AA 3 asset setup uses Sprockets rather
# than importmap, so the macro is undefined and the controller raises NameError at
# boot — strip the line. No-op on Rails < 8.1 (line absent) and harmless on AA 4
# (importmap present), where it only skips an HTTP-caching optimization in specs.
gsub_file 'app/controllers/application_controller.rb',
  /^\s*stale_when_importmap_changes.*\n/, ''

# Add our local Active Admin to the load path (Rails 7.1+)
gsub_file "config/environment.rb",
  'require_relative "application"',
  "require_relative \"application\"\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

aa_v4 = ENV['AA']&.start_with?('4')

generate :'active_admin:install --skip-users'

if aa_v4
  # `active_admin:assets` swaps AA 3's Sprockets SCSS/JS for AA 4's Tailwind CSS
  # stub. We don't compile it — specs assert on DOM and flash text, not styling,
  # so the stub suffices and no Node is needed. `builds/` satisfies cssbundling-rails.
  generate :'active_admin:assets'
  run 'mkdir -p app/assets/builds'
else
  generate :'formtastic:install'
end

run 'rm -rf test'
route "root :to => 'admin/dashboard#index'"
rake 'db:create db:migrate'

run 'rm -f Gemfile Gemfile.lock'
