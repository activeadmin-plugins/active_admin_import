require 'activerecord-import'
require 'active_admin_import/version'
require 'active_admin_import/engine'
require 'active_admin_import/dsl'
require 'active_admin_import/importer'
require 'active_admin_import/model'
::ActiveAdmin::DSL.send(:include, ActiveAdminImport::DSL)
