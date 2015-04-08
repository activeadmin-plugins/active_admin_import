# Rails template to build the sample app for specs

generate :model, 'author name:string{10}:uniq last_name:string birthday:date'
generate :model, 'post title:string:uniq body:text author:references'

#Add validation
inject_into_file "app/models/author.rb", "  validates_presence_of :name\n", after: "Base\n"
inject_into_file "app/models/post.rb", "   validates_presence_of :author\n", after: ":author\n"

# Configure default_url_options in test environment
inject_into_file "config/environments/test.rb", "  config.action_mailer.default_url_options = { :host => 'example.com' }\n", after: "config.cache_classes = true\n"

# Add our local Active Admin to the load path
inject_into_file "config/environment.rb", "\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n", after: "require File.expand_path('../application', __FILE__)"

run "rm Gemfile"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'

run "rm -r test"
run "rm -r spec"

# Setup a root path for devise
route "root :to => 'admin/dashboard#index'"

rake "db:migrate"
