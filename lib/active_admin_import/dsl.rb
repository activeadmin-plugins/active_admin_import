module ActiveAdminImport
  module DSL
    # Declares import functionality
    #
    # Options
    # +back+:: resource action to redirect after processing
    # +col_sep+:: column separator used for CSV parsing (deprecated)
    # +row_sep+:: column separator used for CSV parsing  (deprecated)
    # +csv_options+:: hash to override default CSV options
    # +validate+:: true|false, means perfoem validations or not
    # +batch_size+:: integer value of max  record count inserted by 1 query/transaction
    # +before_import+:: proc for before import action, hook called with  importer object
    # +after_import+:: proc for after import action, hook called with  importer object
    # +before_batch_import+:: proc for before each batch action, called with  importer object
    # +after_batch_import+:: proc for after each batch action, called with  importer object
    # +on_duplicate_key_update+:: an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE ability.
    # +timestamps+::  true|false, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
    # +ignore+::  true|false, tells activerecord-import to use MySQL's INSERT IGNORE ability
    # +template+:: custom template rendering
    # +template_object+:: object passing to view
    # +resource_class+:: resource class name, override to import to another table (default config.resource_class)
    # +resource_label+:: resource label value (default config.resource_label)
    # +plural_resource_label+:: plaralized resource label value (default config.plural_resource_label)
    #
    def active_admin_import options = {}, &block
      default_options = {
          back: {action: :import},
          csv_options: {},
          template: "admin/import",
          resource_class: config.resource_class,
          resource_label: config.resource_label,
          plural_resource_label: config.plural_resource_label,
          headers_rewrites: {}
      }
      options = default_options.deep_merge(options)
      options[:template_object] = ActiveAdminImport::Model.new if options[:template_object].blank?
      params_key = ActiveModel::Naming.param_key(options[:template_object])

      collection_action :import, method: :get do
        authorize!(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)

        @active_admin_import_model = options[:template_object]
        render template: options[:template]
      end

      action_item only: :index do
          link_to(I18n.t('active_admin_import.import_model', model: options[:resource_label]), action: 'import')
        if authorized?(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)
          link_to(I18n.t('active_admin_import.import_model', model: options[:resource_label]), action: 'import')
        end
      end

      collection_action :do_import, method: :post do
        authorize!(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)

        @active_admin_import_model = options[:template_object]
        @active_admin_import_model.assign_attributes(params[params_key].try(:deep_symbolize_keys) || {})
        #go back to form
        return render template: options[:template] unless @active_admin_import_model.valid?
        @importer = Importer.new(options[:resource_class], @active_admin_import_model, options)
        begin
          @importer.import
          if block_given?
            instance_eval &block
          else
            model_name = options[:resource_label].downcase
            plural_model_name = options[:resource_label].downcase
            if @importer.result[:imported].to_i > 0
              flash[:notice] = I18n.t('active_admin_import.imported', count: @importer.result[:imported].to_i, model: model_name, plural_model: plural_model_name)
            end
            if  @importer.result[:failed].count > 0
              flash[:error] = I18n.t('active_admin_import.failed', count: @importer.result[:failed].count, model: model_name, plural_model: plural_model_name)
            end
          end
        rescue ActiveRecord::Import::MissingColumnError, NoMethodError => e
          flash[:error] = e.message
        end
        redirect_to options[:back]
      end

    end
  end
end
