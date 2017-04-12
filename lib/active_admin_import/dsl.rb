# frozen_string_literal: true
module ActiveAdminImport
  # Declares import functionality
  #
  # Options
  # +back+:: resource action to redirect after processing
  # +csv_options+:: hash to override default CSV options
  # +batch_size+:: integer value of max  record count inserted by 1 query/transaction
  # +batch_transaction+:: bool (false by default), if transaction is used when batch importing
  #  and works when :validate is set to true
  # +before_import+:: proc for before import action, hook called with  importer object
  # +after_import+:: proc for after import action, hook called with  importer object
  # +before_batch_import+:: proc for before each batch action, called with  importer object
  # +after_batch_import+:: proc for after each batch action, called with  importer object
  # +validate+:: true|false, means perform validations or not
  # +on_duplicate_key_update+:: an Array or Hash, tells activerecord-import
  # to use MySQL's ON DUPLICATE KEY UPDATE ability.
  # +timestamps+::  true|false, tells activerecord-import to not add timestamps (if false)
  #  even if record timestamps is disabled in ActiveRecord::Base
  # +ignore+::  true|false, tells activerecord-import to use MySQL's INSERT IGNORE ability
  # +template+:: custom template rendering
  # +template_object+:: object passing to view
  # +resource_class+:: resource class name, override to import to another table (default config.resource_class)
  # +resource_label+:: resource label value (default config.resource_label)
  # +plural_resource_label+:: pluralized resource label value (default config.plural_resource_label)
  #
  module DSL
    DEFAULT_RESULT_PROC = lambda do |result, options|
      model_name = options[:resource_label].downcase
      plural_model_name = options[:plural_resource_label].downcase
      if result.empty?
        flash[:warning] = I18n.t('active_admin_import.file_empty_error')
      else
        if result.failed?
          flash[:error] = I18n.t(
            'active_admin_import.failed',
            count: result.failed.count,
            model: model_name,
            plural_model: plural_model_name,
            message: result.failed_message(limit: options[:error_limit]))
          return if options[:batch_transaction]
        end
        if result.imported?
          flash[:notice] = I18n.t(
            'active_admin_import.imported',
            count: result.imported_qty,
            model: model_name,
            plural_model: plural_model_name)
        end
      end
    end
    # rubocop:disable Metrics/AbcSize
    def active_admin_import(options = {}, &block)
      options.assert_valid_keys(*Options::VALID_OPTIONS)

      options = Options.options_for(config, options)
      params_key = ActiveModel::Naming.param_key(options[:template_object])

      collection_action :import, method: :get do
        authorize!(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)
        @active_admin_import_model = options[:template_object]
        render template: options[:template]
      end

      action_item :import, only: :index, if: options[:if] do
        if authorized?(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)
          link_to(
            I18n.t('active_admin_import.import_model', plural_model: options[:plural_resource_label]),
            action: :import
          )
        end
      end

      collection_action :do_import, method: :post do
        authorize!(ActiveAdminImport::Auth::IMPORT, active_admin_config.resource_class)
        _params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params
        params = ActiveSupport::HashWithIndifferentAccess.new _params
        @active_admin_import_model = options[:template_object]
        @active_admin_import_model.assign_attributes(params[params_key].try(:deep_symbolize_keys) || {})
        # go back to form
        return render template: options[:template] unless @active_admin_import_model.valid?
        @importer = Importer.new(
          options[:resource_class],
          @active_admin_import_model,
          options
        )
        begin
          result = @importer.import

          if block_given?
            instance_eval(&block)
          else
            instance_exec result, options, &DEFAULT_RESULT_PROC
          end
        rescue ActiveRecord::Import::MissingColumnError, NoMethodError, ActiveRecord::StatementInvalid, CSV::MalformedCSVError => e
          Rails.logger.error(I18n.t('active_admin_import.file_error', message: e.message))
          Rails.logger.error(e.backtrace.join("\n"))
          flash[:error] = I18n.t('active_admin_import.file_error', message: e.message[0..200])
        end
        redirect_to options[:back]
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
