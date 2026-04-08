# ActiveAdminImport

[![Build Status][build_badge]][build_link]
![Coverage][coverage_badge]
[![Code Climate][codeclimate_badge]][codeclimate_link]
[![Gem Version][rubygems_badge]][rubygems_link]
[![License][license_badge]][license_link]


The fastest and most efficient CSV import for Active Admin with support for validations, bulk inserts, and encoding handling.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "active_admin_import"
```
or

```ruby
gem "active_admin_import" , github: "activeadmin-plugins/active_admin_import"
```

And then execute:

    $ bundle


## Features
* Replacements/Updates support
* Encoding handling
* CSV options
* Ability to describe/change CSV headers
* Bulk import (activerecord-import)
* Callbacks
* Zip files
* and more...


#### Basic usage

```ruby
ActiveAdmin.register Post do
  active_admin_import options
end
```


#### Options
Tool                    | Description
---------------------   | -----------
:back                   |resource action to redirect after processing
:csv_options            |hash with column separator, row separator, etc
:validate               |bool (true by default), perform validations or not
:batch_transaction      |bool (false by default), if transaction is used when batch importing and works when :validate is set to true
:batch_size             |integer value of max  record count inserted by 1 query/transaction
:before_import          |proc for before import action, hook called with  importer object
:after_import           |proc for after import action, hook called with  importer object
:before_batch_import    |proc for before each batch action, called with  importer object
:after_batch_import     |proc for after each batch action, called with  importer object
:on_duplicate_key_update|an Array or Hash, tells activerecord-import to use MySQL's ON DUPLICATE KEY UPDATE or Postgres 9.5+/SQLite 3.24.0+ ON CONFLICT DO UPDATE ability
:on_duplicate_key_ignore|bool, tells activerecord-import to use MySQL's INSERT IGNORE or Postgres 9.5+ ON CONFLICT DO NOTHING or SQLite's INSERT OR IGNORE ability
:ignore                 |bool, alias for on_duplicate_key_ignore
:timestamps             |bool, tells activerecord-import to not add timestamps (if false) even if record timestamps is disabled in ActiveRecord::Base
:template               |custom template rendering
:template_object        |object passing to view
:result_class           |custom `ImportResult` subclass to collect data from each batch (e.g. inserted ids). Must respond to `add(batch_result, qty)` plus the readers used in flash messages (`failed`, `total`, `imported_qty`, `imported?`, `failed?`, `empty?`, `failed_message`).
:resource_class         |resource class name
:resource_label         |resource label value
:plural_resource_label  |pluralized resource label value (default config.plural_resource_label)
:error_limit            |Limit the number of errors reported (default `5`, set to `nil` for all)
:headers_rewrites       |hash with key (csv header) - value (db column name) rows mapping
:if                     |Controls whether the 'Import' button is displayed. It supports a proc to be evaluated into a boolean value within the activeadmin render context.



#### Custom ImportResult

To collect extra data from each batch (for example the ids of inserted rows so you can enqueue background jobs against them), pass a subclass of `ActiveAdminImport::ImportResult` via `:result_class`:

```ruby
class ImportResultWithIds < ActiveAdminImport::ImportResult
  attr_reader :ids

  def initialize
    super
    @ids = []
  end

  def add(batch_result, qty)
    super
    @ids.concat(Array(batch_result.ids))
  end
end

ActiveAdmin.register Author do
  active_admin_import result_class: ImportResultWithIds do |result, options|
    EnqueueAuthorsJob.perform_later(result.ids) if result.imported?
    instance_exec(result, options, &ActiveAdminImport::DSL::DEFAULT_RESULT_PROC)
  end
end
```

The action block is invoked via `instance_exec` with `result` and `options` as block arguments, so you can either capture them with `do |result, options|` or read them as locals when no arguments are declared.

Note: which batch-result attributes are populated depends on the database adapter and the import options. `activerecord-import` returns ids reliably on PostgreSQL; on MySQL/SQLite the behavior depends on the adapter and options like `on_duplicate_key_update`. Putting the collection logic in your own subclass keeps these adapter quirks in your application code.


#### Authorization

The current user must be authorized to perform imports. With CanCanCan:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :import, Post
  end
end
```


#### Per-request context

Define an `active_admin_import_context` method on the controller to inject request-derived attributes into every import (current user, parent resource id, request IP, etc.). The returned hash is merged into the import model after form params, so it always wins for the keys it provides:

```ruby
ActiveAdmin.register PostComment do
  belongs_to :post

  controller do
    def active_admin_import_context
      { post_id: parent.id, request_ip: request.remote_ip }
    end
  end

  active_admin_import before_batch_import: ->(importer) {
    importer.csv_lines.map! { |row| row << importer.model.post_id }
    importer.headers.merge!(:'Post Id' => :post_id)
  }
end
```


#### Examples

##### Files without CSV headers

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: true,
                      template_object: ActiveAdminImport::Model.new(
                        hint: "expected header order: body, title, author",
                        csv_headers: %w[body title author]
                      )
end
```

##### Auto-detect file encoding

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: true,
                      template_object: ActiveAdminImport::Model.new(force_encoding: :auto)
end
```

##### Force a specific (non-UTF-8) encoding

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: true,
                      template_object: ActiveAdminImport::Model.new(
                        hint: "file is encoded in ISO-8859-1",
                        force_encoding: "ISO-8859-1"
                      )
end
```

##### Disallow ZIP upload

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: true,
                      template_object: ActiveAdminImport::Model.new(
                        hint: "upload a CSV file",
                        allow_archive: false
                      )
end
```

##### Skip CSV columns

Useful when the CSV file has columns that don't exist on the table. Available since 3.1.0.

```ruby
ActiveAdmin.register Post do
  active_admin_import before_batch_import: ->(importer) {
    importer.batch_slice_columns(['name', 'last_name'])
  }
end
```

Tip: pass `Post.column_names` to keep only the columns that exist on the table.

##### Resolve associations on the fly

Replace an `Author name` column in the CSV with the matching `author_id` before insert:

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: true,
                      headers_rewrites: { 'Author name': :author_id },
                      before_batch_import: ->(importer) {
                        names = importer.values_at(:author_id)
                        mapping = Author.where(name: names).pluck(:name, :id).to_h
                        importer.batch_replace(:author_id, mapping)
                      }
end
```

##### Update existing records by id

Delete colliding rows just before each batch insert:

```ruby
ActiveAdmin.register Post do
  active_admin_import before_batch_import: ->(importer) {
    Post.where(id: importer.values_at('id')).delete_all
  }
end
```

For databases that support upserts you can use `:on_duplicate_key_update` instead.

##### Tune batch size

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: false,
                      csv_options: { col_sep: ";" },
                      batch_size: 1000
end
```

##### Import into an intermediate table

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: false,
                      csv_options: { col_sep: ";" },
                      resource_class: ImportedPost,                # write to a staging table
                      before_import: ->(_) { ImportedPost.delete_all },
                      after_import: ->(_) {
                        Post.transaction do
                          Post.delete_all
                          Post.connection.execute("INSERT INTO posts (SELECT * FROM imported_posts)")
                        end
                      },
                      back: ->(_) { config.namespace.resource_for(Post).route_collection_path }
end
```

##### Allow user input for CSV options (custom template)

```ruby
ActiveAdmin.register Post do
  active_admin_import validate: false,
                      template: 'admin/posts/import',
                      template_object: ActiveAdminImport::Model.new(
                        hint: "you can configure CSV options",
                        csv_options: { col_sep: ";", row_sep: nil, quote_char: nil }
                      )
end
```

`app/views/admin/posts/import.html.erb`:

```erb
<p><%= raw(@active_admin_import_model.hint) %></p>

<%= semantic_form_for @active_admin_import_model, url: { action: :do_import }, html: { multipart: true } do |f| %>
  <%= f.inputs do %>
    <%= f.input :file, as: :file %>
  <% end %>

  <%= f.inputs "CSV options", for: [:csv_options, OpenStruct.new(@active_admin_import_model.csv_options)] do |csv| %>
    <% csv.with_options input_html: { style: 'width:40px;' } do |opts| %>
      <%= opts.input :col_sep %>
      <%= opts.input :row_sep %>
      <%= opts.input :quote_char %>
    <% end %>
  <% end %>

  <%= f.actions do %>
    <%= f.action :submit,
                 label: t("active_admin_import.import_btn"),
                 button_html: { disable_with: t("active_admin_import.import_btn_disabled") } %>
  <% end %>
<% end %>
```

##### Inspecting the importer in batch callbacks

Both `before_batch_import` and `after_batch_import` receive the `Importer` instance:

```ruby
active_admin_import before_batch_import: ->(importer) {
  importer.file        # the uploaded file
  importer.resource    # the ActiveRecord class being imported into
  importer.options     # the resolved options hash
  importer.headers     # CSV headers (mutable)
  importer.csv_lines   # parsed CSV rows for the current batch (mutable)
  importer.model       # the template_object instance
}
```


## Dependencies

Tool                  | Description
--------------------- | -----------
[rchardet]            | Character encoding auto-detection in Ruby. As smart as your browser. Open source.
[activerecord-import] | Powerful library for bulk inserting data using ActiveRecord.

[rchardet]: https://github.com/jmhodges/rchardet
[activerecord-import]: https://github.com/zdennis/activerecord-import

[build_badge]: https://github.com/activeadmin-plugins/active_admin_import/actions/workflows/test.yml/badge.svg
[build_link]: https://github.com/activeadmin-plugins/active_admin_import/actions
[coverage_badge]: https://img.shields.io/endpoint?url=https://activeadmin-plugins.github.io/active_admin_import/badge.json
[codeclimate_badge]: https://codeclimate.com/github/activeadmin-plugins/active_admin_import/badges/gpa.svg
[codeclimate_link]: https://codeclimate.com/github/activeadmin-plugins/active_admin_import
[rubygems_badge]: https://badge.fury.io/rb/active_admin_import.svg
[rubygems_link]: https://rubygems.org/gems/active_admin_import
[license_badge]: https://img.shields.io/:license-mit-blue.svg
[license_link]: https://Fivell.mit-license.org


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
