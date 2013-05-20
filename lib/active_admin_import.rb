require 'activerecord-import'
require 'active_admin_import/version'
require 'active_admin_import/engine'
require 'active_admin_import/dsl'
require 'active_admin_import/importer'
require 'active_admin_import/model'
::ActiveAdmin::DSL.send(:include, ActiveAdminImport::DSL)

module ActiveAdminImport
    class Railtie < ::Rails::Railtie
    config.after_initialize do
      require 'active_support/i18n'
      I18n.load_path.unshift *Dir[File.expand_path('../active_admin_import/locales/*.yml', __FILE__)]
    end
  end
end