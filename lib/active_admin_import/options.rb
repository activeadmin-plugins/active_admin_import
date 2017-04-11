# frozen_string_literal: true
module ActiveAdminImport
  module Options
    VALID_OPTIONS = [
      :back,
      :csv_options,
      :validate,
      :batch_size,
      :batch_transaction,
      :before_import,
      :after_import,
      :before_batch_import,
      :after_batch_import,
      :on_duplicate_key_update,
      :timestamps,
      :ignore,
      :template,
      :template_object,
      :resource_class,
      :resource_label,
      :plural_resource_label,
      :error_limit,
      :headers_rewrites,
      :if
    ].freeze

    def self.options_for(config, options = {})
      unless options.key? :template_object
        options[:template_object] = ActiveAdminImport::Model.new
      end

      {
        back: { action: :import },
        csv_options: {},
        template: 'admin/import',
        resource_class: config.resource_class,
        resource_label: config.resource_label,
        plural_resource_label: config.plural_resource_label,
        error_limit: 5,
        headers_rewrites: {},
        if: true
      }.deep_merge(options)
    end
  end
end
