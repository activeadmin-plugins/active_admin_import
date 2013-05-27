module ActiveAdminImport
  module DSL


    # Declares import functionality
    #
    # Options
    # +back+:: resource action to redirect after processing
    # +col_sep+:: column separator used for CSV parsing
    # +validate+:: true|false, means perfoem validations or not
    # +batch_size+:: integer value of max  record count inserted by 1 query/transaction
    # +before_import+:: proc for before import action, hook called with  importer object
    # +after_import+:: proc for after import action, hook called with  importer object
    # +before_batch_import+:: proc for before each batch action, called with  importer object
    # +after_batch_import+:: proc for after each batch action, called with  importer object
    # +on_duplicate_key_update+:: an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE ability.
    # +timestamps+::  true|false, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
    # +ignore+::  true|false, tells activerecord-import toto use MySQL's INSERT IGNORE ability
    # +fetch_extra_options_from_params+:: params values available in callbacks in importer.extra_options hash
    # +template+:: custom template rendering
    # +template_object+:: object passing to view
    # +resource_class+:: resource class name
    # +resource_label+:: resource label value
    #
    def active_admin_import options = {}
      default_options = {
          :back => :import,
          :col_sep => ',',
          :template => "admin/import",
          :template_object => ActiveAdminImport::Model.new,
          :fetch_extra_options_from_params => [],
          :resource_class => nil,
          :resource_label => nil,
          :headers_rewrites => {}


      }
      options = default_options.merge(options)
      params_key = ActiveModel::Naming.param_key(options[:template_object])


      collection_action :import, :method => :get do
        @active_admin_import_model = options[:template_object]
        render :template => options[:template]
      end


      action_item :only => :index do
        link_to(I18n.t('active_admin_import.import_model',
                :model => (options[:resource_label] || active_admin_config.resource_name)),
                        :action => 'import')
      end


      collection_action :do_import, :method => :post do
        if params[params_key].blank?
          flash[:alert] =  I18n.t('active_admin_import.no_file_error')
          return redirect_to :back
        end
        content_types_allow = [
            'text/csv',
            'text/x-csv',
            'text/comma-separated-values',
            'application/csv',
            'application/vnd.ms-excel',
            'application/vnd.msexcel'
        ]
        unless params[params_key]['file'].try(:content_type) && params[params_key]['file'].content_type.in?(content_types_allow)
          flash[:alert] = I18n.t('active_admin_import.file_format_error')
          return redirect_to :back
        end

        importer = Importer.new((options[:resource_class] || active_admin_config.resource_class),
                                params[params_key][:file],
                                options,
                                params[params_key].to_hash.slice(*options[:fetch_extra_options_from_params])
        )
        result = importer.import

        flash[:notice] =  I18n.t('active_admin_import.imported',
                                    :count=> result[:imported].to_i,
                                    :model => (options[:resource_label] || active_admin_config.resource_label).downcase,
                                    :plural_model =>  (options[:resource_label].present? ? options[:resource_label].to_s.pluralize : active_admin_config.plural_resource_label).downcase

                                ) if  result[:imported].to_i > 0

        flash[:error] =  I18n.t('active_admin_import.failed',
                                    :count=> result[:failed].count,
                                    :model => (options[:resource_label] || active_admin_config.resource_label).downcase,
                                     :plural_model =>  (options[:resource_label].present? ? options[:resource_label].to_s.pluralize : active_admin_config.plural_resource_label).downcase

                                ) if  result[:failed].count > 0

        redirect_to :action => options[:back]
      end

    end
  end
end
