require "bundler"
require 'rake'
Bundler.setup
Bundler::GemHelper.install_tasks
FileList['tasks/**/*.rake'].each { |task| import task }
