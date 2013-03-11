# ActiveAdminImport
CSV imports for Active Admin based on activerecord-import gem


#Example
  
    ActiveAdmin.register Post  do
       active_admin_import :validate => false,
                            :col_sep => ',',
                            :back => :index ,
                            :before_import => proc{|data|  Post.delete_all  if data.count > 0 }
    
    
    end



