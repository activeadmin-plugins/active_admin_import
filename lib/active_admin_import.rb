require 'activerecord-import'
require 'active_admin_import/version'
require 'active_admin_import/engine'
require 'active_admin_import/dsl'
require 'active_admin_import/import'

::ActiveAdmin::DSL.send(:include, ActiveAdminImport::DSL)
