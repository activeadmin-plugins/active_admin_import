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
