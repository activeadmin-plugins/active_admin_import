require 'activerecord-import'
require 'active_admin'
require 'active_admin_import/version'
require 'active_admin_import/engine'
require 'active_admin_import/import_result'
require 'active_admin_import/options'
require 'active_admin_import/dsl'
require 'active_admin_import/importer'
require 'active_admin_import/model'
require 'active_admin_import/authorization'
::ActiveAdmin::DSL.send(:include, ActiveAdminImport::DSL)


