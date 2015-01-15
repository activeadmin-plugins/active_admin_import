def add_author_resource(options = {})

  ActiveAdmin.register Author do
     active_admin_import(options)
  end
  Rails.application.reload_routes!

end
