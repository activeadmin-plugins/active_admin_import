def add_author_resource(options = {}, &block)

  ActiveAdmin.register Author do
     active_admin_import(options, &block)
  end
  Rails.application.reload_routes!

end
