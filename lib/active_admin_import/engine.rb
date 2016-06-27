# frozen_string_literal: true
require 'rails'

module ActiveAdminImport
  class Engine < ::Rails::Engine
    config.mount_at = '/'
  end
end
