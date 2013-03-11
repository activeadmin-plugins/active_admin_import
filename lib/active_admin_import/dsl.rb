module ActiveAdminImport
  module DSL


    # Declares import functionality
    #
    # Options
    # +back+:: resource action to redirect after processing
    # +col_sep+:: column separator used for CSV parsing
    # +validate+:: true|false, means perfoem validations or not
    # +batch_size+:: integer value of max  record count inserted by 1 query/transaction
    # +before_import+:: proc for before import action, called with resource, file, options arguments
    # +before_batch_import+:: proc for before each batch action, called with imported data and headers arguments
    # +after_batch_import+:: proc for after each batch action, called with imported data and headers arguments
    # +on_duplicate_key_update+:: an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE ability.
    # +timestamps+::  true|false, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
    # +ignore+::  true|false, tells activerecord-import toto use MySQL's INSERT IGNORE ability
    def active_admin_import options = {}
      default_options = {
        :back => :import,
        :col_sep => ','
      }
      options = default_options.merge(options)
      action_item :only => :index do
        link_to "Import #{active_admin_config.resource_name.pluralize}", :action => 'import'
      end

      collection_action :import, :method => :get do
        render "admin/import"
      end

      collection_action :do_import, :method => :post do
        if params[:import].blank?
          flash[:alert] = "Please, select file to import"
          return redirect_to :action => options[:back]
        end
        unless params[:import]['file'].try(:content_type) && params[:import]['file'].content_type.in?(["text/csv"])
          flash[:alert] = "You can import file only with extension csv"
          return redirect_to :action => options[:back]
        end
        importer = Importer.new( active_admin_config.resource_class, params[:import][:file], options)


          result = importer.import
          flash[:notice] = "#{view_context.pluralize(result[:imported].to_i,active_admin_config.resource_name)} was imported"
          unless result[:failed].count == 0
            flash[:error] =  "#{view_context.pluralize(result[:failed].count,active_admin_config.resource_name)} was failed to imported"
          end

        redirect_to :action => options[:back]
      end

    end
  end
end
