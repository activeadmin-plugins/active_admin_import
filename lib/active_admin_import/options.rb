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
        :headers_rewrites
    ].freeze


    def self.options_for(config, options= {})
      options[:template_object] = ActiveAdminImport::Model.new  unless options.has_key? :template_object

      {
          back: {action: :import},
          csv_options: {},
          template: "admin/import",
          resource_class: config.resource_class,
          resource_label: config.resource_label,
          plural_resource_label: config.plural_resource_label,
          headers_rewrites: {}
      }.deep_merge(options)



    end

  end
end
