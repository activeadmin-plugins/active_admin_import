# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require File.expand_path('../lib/active_admin_import/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ['Igor Fedoronchuk']
  gem.email = ['fedoronchuk@gmail.com']
  gem.description = 'The most efficient way to import for Active Admin'
  gem.summary = 'ActiveAdmin import based on activerecord-import gem.'
  gem.homepage = 'https://github.com/activeadmin-plugins/active_admin_import'
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 3.1.0'
  gem.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.name = 'active_admin_import'
  gem.require_paths = ['lib']
  gem.version = ActiveAdminImport::VERSION
  gem.add_runtime_dependency 'activerecord-import', '>= 2.0'
  gem.add_runtime_dependency 'rchardet', '>= 1.6'
  gem.add_runtime_dependency 'rubyzip', '>= 1.2'
  gem.add_dependency 'activeadmin', '>= 3.0', '< 4.0'
end
