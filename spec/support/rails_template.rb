create_file "app/assets/config/manifest.js", skip: true

generate :model, 'author name:string{10}:uniq last_name:string birthday:date --force'
generate :model, 'post title:string:uniq body:text request_ip:string author:references --force'
generate :model, 'post_comment body:text post:references --force'

inject_into_file 'app/models/author.rb', "  validates_presence_of :name\n  validates_uniqueness_of :last_name\n", before: 'end'
inject_into_file 'app/models/post.rb', "  validates_presence_of :author\n  has_many :post_comments\n", before: 'end'

# Add our local Active Admin to the load path (Rails 7.1+)
gsub_file "config/environment.rb",
  'require_relative "application"',
  "require_relative \"application\"\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'

run 'rm -rf test'
route "root :to => 'admin/dashboard#index'"
rake 'db:migrate'

run 'rm -f Gemfile Gemfile.lock'
