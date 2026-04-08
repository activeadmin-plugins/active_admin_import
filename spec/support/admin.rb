# frozen_string_literal: true
def add_author_resource(options = {}, &block)
  ActiveAdmin.register Author do
    config.filters = false
    active_admin_import(options, &block)
  end
  Rails.application.reload_routes!
end

def add_post_resource(options = {}, &block)
  cb = options.delete(:controller_block)
  ActiveAdmin.register Post do
    config.filters = false
    controller(&cb) if cb
    active_admin_import(options, &block)
  end
  Rails.application.reload_routes!
end

def add_nested_post_comment_resource(options = {}, &block)
  cb = options.delete(:controller_block)
  ActiveAdmin.register Post do
    config.filters = false
  end
  ActiveAdmin.register PostComment do
    config.filters = false
    belongs_to :post
    controller(&cb) if cb
    active_admin_import(options, &block)
  end
  Rails.application.reload_routes!
end
