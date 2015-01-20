# ActiveAdminImport 
The most fastest and efficient CSV import for Active Admin
with support of validations, bulk inserts and encodings handling



[![Build Status](http://img.shields.io/travis/Fivell/active_admin_import.svg)](https://travis-ci.org/Fivell/active_admin_import)
[![Dependency Status](http://img.shields.io/gemnasium/Fivell/active_admin_import.svg)](https://gemnasium.com/Fivell/active_admin_import)
[![Coverage Status](https://coveralls.io/repos/Fivell/active_admin_import/badge.svg?branch=3.0.0)](https://coveralls.io/r/Fivell/active_admin_import?branch=3.0.0)

[![Code Climate](http://img.shields.io/codeclimate/github/Fivell/active_admin_import.svg)](https://codeclimate.com/github/Fivell/active_admin_import)
[![Gem Version](http://img.shields.io/gem/v/active_admin_import.svg)](https://rubygems.org/gems/active_admin_import)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://Fivell.mit-license.org)

master can be used with AA 1.0.0 and Rails >= 4.1


#Installation

Add this line to your application's Gemfile:

```ruby
gem "active_admin_import" , '2.1.2'

```
or

```ruby
gem "active_admin_import" , github: "Fivell/active_admin_import"

```

And then execute:

    $ bundle


# active_admin_import features
<ol>
  <li> Replacements (Ex 2)</li>
  <li> Encoding handling (Ex 4, 5)</li>
  <li> CSV options</li>
  <li> Ability to prepend CSV headers automatically</li>
  <li> Bulk import (activerecord-import)</li>
  <li> Callbacks</li>
  <li> Zip files</li>
  <li> more...</li>
</ol>

   


#### Options
Tool                    | Description
---------------------   | -----------
:back					|resource action to redirect after processing
:csv_options			|hash with column separator, row separator, etc 
:validate				|bool means perform validations or not
:batch_size				|integer value of max  record count inserted by 1 query/transaction
:before_import			|proc for before import action, hook called with  importer object
:after_import			|proc for after import action, hook called with  importer object
:before_batch_import	|proc for before each batch action, called with  importer object
:after_batch_import		|proc for after each batch action, called with  importer object
:on_duplicate_key_update|an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE ability.
:timestamps				|bool, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
:ignore					|bool, tells activerecord-import toto use MySQL's INSERT IGNORE ability
:template				|custom template rendering
:template_object		|object passing to view
:resource_class			|resource class name
:resource_label			|resource label value
:plural_resource_label	|pluralized resource label value (default config.plural_resource_label)
:headers_rewrites		|hash with key (csv header) - value (db column name) rows mapping



#### Default options values

```ruby    
    back: {action: :import},
    csv_options: {},
    template: "admin/import",
    fetch_extra_options_from_params: [],
    resource_class: config.resource_class,
    resource_label:  config.resource_label,
    plural_resource_label: config.plural_resource_label,
```    

#### Example1 

```ruby  
    ActiveAdmin.register Post  do
       active_admin_import  validate: false,
                            csv_options: {col_sep: ";" },
                            before_import: proc{ Post.delete_all},
                            batch_size: 1000
    
    
    end
```


#### Example2 Importing to mediate table with insert select operation after import completion

<p> This config allows to replace data in 1 sql query with callback </p>

```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: false,
            csv_options: {col_sep: ";" },
            resource_class: ImportedPost ,  # we import data into another resource
            before_import: proc{ ImportedPost.delete_all },
            after_import: proc{
                Post.transaction do
                    Post.delete_all
                    Post.connection.execute("INSERT INTO posts (SELECT * FROM imported_posts)")
                end
            },
            back: proc { config.namespace.resource_for(Post).route_collection_path } # redirect to post index
    end
```


#### Example3 Importing file without headers, but we always know file format, so we can predefine it

```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: true,
            template_object: ActiveAdminImport::Model.new(
                hint: "file will be imported with such header format: 'body','title','author'",
                csv_headers: ["body","title","author"]
            )
    end
```
 
#### Example4 Importing  ISO-8859-1 encoded file and disallow archives


```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: true,
            template_object: ActiveAdminImport::Model.new(
                hint: "file encoded in ISO-8859-1",
                force_encoding: "ISO-8859-1",
                allow_archive: false
            )
    end
```

#### Example5 Importing file with unknown encoding and autodetect it


```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: true,
            template_object: ActiveAdminImport::Model.new(
                force_encoding: :auto
            )
    end
```

#### Example6 Callbacks for each bulk insert iteration


```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: true,
        before_batch_import: proc { |import|
           import.file #current file used
           import.resource #ActiveRecord class to import to
           import.options # options
           import.result # result before bulk iteration
           import.headers # CSV headers
           import.csv_lines #lines to import
           import.model #template_object instance
        },
        after_batch_import: proc{ |import|
           #the same
        }
    end
```    
    
#### Example7 dynamic CSV options, template overriding

 -  put overrided template to ```app/views/import.html.erb```

```erb

    <p>
       <%= raw(@active_admin_import_model.hint) %> 
    </p>
    <%= semantic_form_for @active_admin_import_model, url: {action: :do_import}, html: {multipart: true} do |f| %>
        <%= f.inputs do %>
            <%= f.input :file, as: :file %>
        <% end %>
        <%= f.inputs "CSV options", for: [:csv_options, OpenStruct.new(@active_admin_import_model.csv_options)] do |csv| %>
            <% csv.with_options input_html: {style: 'width:40px;'} do |opts| %>
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

 - call method with following parameters

```ruby
    ActiveAdmin.register Post  do
        active_admin_import validate: false,
                          template: 'import' ,
                          template_object: ActiveAdminImport::Model.new(
                              hint: "specify CSV options"
                              csv_options: {col_sep: ";", row_sep: nil, quote_char: nil}
                          )
    end                      
```

## Dependencies

Tool                  | Description
--------------------- | -----------
[rchardet]            | Character encoding auto-detection in Ruby. As smart as your browser. Open source.
[activerecord-import] | Powerful library for bulk inserting data using ActiveRecord.

[rchardet]: https://github.com/jmhodges/rchardet
[activerecord-import]: https://github.com/jmhodges/rchardet









