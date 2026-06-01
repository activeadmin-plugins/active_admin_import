# frozen_string_literal: true

module TestAppPaths
  module_function

  def app_dir_name
    "rails-#{Rails::VERSION::STRING}-#{ENV['DB'] || 'sqlite'}-aa#{ENV['AA'] || 'default'}"
  end

  # Absolute path under spec/rails/, used as RAILS_ROOT.
  def app_root
    File.expand_path("../rails/#{app_dir_name}", __dir__)
  end
end
