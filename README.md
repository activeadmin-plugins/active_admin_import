# ActiveAdminImport 
The most fastest and efficient CSV import for Active Admin (based on activerecord-import gem) 
with support of validations and bulk inserts 


Should work with both AA 0.6 and 1.0.0


#Installation

Add this line to your application's Gemfile:

```ruby
gem "active_admin_import" , '2.1.1'
```
	
And then execute:

    $ bundle



Why yet another import for ActiveAdmin ? Now with activerecord-import ....

    "Because plain-vanilla, out-of-the-box ActiveRecord doesn’t provide support for inserting large amounts of data efficiently"

cool features of activerecord-import

    activerecord-import can perform validations (fast)
    activerecord-import can perform on duplicate key updates (requires mysql)


So active_admin_import features

    Encoding handling
    Two step importing (see example2)
    CSV options
    Ability to prepend CSV headers automatically
    Bulk import (activerecord-import)
    Ability to customize template 
    Callbacks support
    Zip files import
    and more ....

Options

    # +back+:: resource action to redirect after processing
    # +csv_options+:: hash with column separator, row separator, etc 
    # +validate+:: true|false, means perfoem validations or not
    # +batch_size+:: integer value of max  record count inserted by 1 query/transaction
    # +before_import+:: proc for before import action, hook called with  importer object
    # +after_import+:: proc for after import action, hook called with  importer object
    # +before_batch_import+:: proc for before each batch action, called with  importer object
    # +after_batch_import+:: proc for after each batch action, called with  importer object
    # +on_duplicate_key_update+:: an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE ability.
    # +timestamps+::  true|false, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
    # +ignore+::  true|false, tells activerecord-import toto use MySQL's INSERT IGNORE ability
    # +params_keys+:: params values available in callbacks
    # +template+:: custom template rendering
    # +template_object+:: object passing to view
    # +locals+:: local variables for template
    # +resource_class+:: resource class name
    # +resource_label+:: resource label value
    # +headers_rewrites+:: hash with key (csv header) - value (db column name) rows mapping



Default options values

```ruby    
    back: {action: :import},
    csv_options: {},
    template: "admin/import",
    fetch_extra_options_from_params: [],
    resource_class: config.resource_class,
    resource_label:  config.resource_label,
    plural_resource_label: config.plural_resource_label,
```    

Example1 

```ruby  
    ActiveAdmin.register Post  do
       active_admin_import :validate => false,
                            :csv_options => {:col_sep => ";" },
                            :before_import => proc{ Post.delete_all},
                            :batch_size => 1000
    
    
    end
```


Example2 Importing to mediate table with insert select operation after import completion

This config allows to replace data without downtime

```ruby
    ActiveAdmin.register Post  do
        active_admin_import :validate => false,
            :csv_options => {:col_sep => ";" },
            :resource_class => ImportedPost ,  # we import data into another resource
            :before_import => proc{ ImportedPost.delete_all },
            :after_import => proc{
                Post.transaction do
                    Post.delete_all
                    Post.connection.execute("INSERT INTO posts (SELECT * FROM import_posts)")
                end
            },
            :back => proc { config.namespace.resource_for(Post).route_collection_path } # redirect to post index
    end
```


Example3 Importing file without headers, but we always know file format, so we can predefine it

```ruby
    ActiveAdmin.register Post  do
        active_admin_import :validate => true,
            :template_object => ActiveAdminImport::Model.new(
                :hint => "file will be imported with such header format: 'body','title','author'",
                :csv_headers => ["body","title","author"] 
            )
    end
```
 
Example4 Importing without forcing to UTF-8 and disallow archives


```ruby
    ActiveAdmin.register Post  do
        active_admin_import :validate => true,
            :template_object => ActiveAdminImport::Model.new(
                :hint => "file will be encoded to ISO-8859-1",
                :force_encoding => "ISO-8859-1",
                :allow_archive => false  
            )
    end
```


Example5 Callbacks for each bulk insert iteration


```ruby
    ActiveAdmin.register Post  do
        active_admin_import :validate => true,
        :before_batch_import => proc { |import|
           import.file #current file used
           import.resource #ActiveRecord class to import to
           import.options # options
           import.result # result before bulk iteration
           import.headers # CSV headers
           import.csv_lines #lines to import
           import.model #template_object instance
        },
        :before_batch_import => proc{ |import|
           #the same
        }
    end
```    
    
Example6 dynamic CSV options, template overriding

1) put overrided template to app/views/import.html.erb

```erb

    <p>
       <%= raw(@active_admin_import_model.hint) %> 
    </p>
    <%= semantic_form_for @active_admin_import_model, url: {action: :do_import}, html: {multipart: true} do |f| %>
        <%= f.inputs do %>
            <%= f.input :file, as: :file %>
        <% end %>
        <%= f.inputs "CSV options", :for => [:csv_options, OpenStruct.new(@active_admin_import_model.csv_options)] do |csv| %>
            <% csv.with_options :input_html => {:style => 'width:40px;'} do |opts| %>
                <%= opts.input :col_sep %>
                <%= opts.input :row_sep %>
                <%= opts.input :quote_char %>
            <% end %>
        <% end %>
    
        <%= f.actions do %>
            <%= f.action :submit, label: t("active_admin_import.import_btn"), button_html: {disable_with: t("active_admin_import.import_btn_disabled")} %>
        <% end %>
    <% end %>
    
```

2) call method with following parameters

```ruby
    ActiveAdmin.register Post  do
        active_admin_import :validate => false,
                          :template => 'import' ,
                          :template_object => ActiveAdminImport::Model.new(
                              :hint => "specify CSV options"
                              :csv_options => {:col_sep => ";", :row_sep => nil, :quote_char => nil} 
                          )
    end                      
```

#Links
https://github.com/gregbell/active_admin

https://github.com/zdennis/activerecord-import

#Source Doc
http://rubydoc.info/gems/active_admin_import/2.1.1/




