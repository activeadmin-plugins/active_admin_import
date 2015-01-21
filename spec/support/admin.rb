def add_author_resource(options = {}, &block)

  ActiveAdmin.register Author do
     config.filters = false
     active_admin_import(options, &block)
  end
  Rails.application.reload_routes!

end


def add_post_resource(options = {}, &block)

  ActiveAdmin.register Post do
     config.filters = false
     active_admin_import(options, &block)
  end
  Rails.application.reload_routes!

end
