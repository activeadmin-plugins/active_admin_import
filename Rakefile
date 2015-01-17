require "bundler"
require 'rake'
Bundler.setup
Bundler::GemHelper.install_tasks

# Import all our rake tasks
FileList['tasks/**/*.rake'].each { |task| import task }