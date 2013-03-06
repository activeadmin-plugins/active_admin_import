module ActiveAdminImport
  module DSL

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
        begin
          result = Import.import active_admin_config.resource_class, params[:import][:file], options
          flash[:notice] = "#{view_context.pluralize(result[:num_inserts].to_i,active_admin_config.resource_name)} was imported"
          unless result[:failed_instances].count == 0
            flash[:error] =  "#{view_context.pluralize(result[:failed_instances].count,active_admin_config.resource_name)} was failed to imported"
          end
        rescue StandardError=>e
          flash[:error] = e.message
        end
        redirect_to :action => options[:back]
      end

    end
  end
end
