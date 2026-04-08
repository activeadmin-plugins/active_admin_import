# ActiveAdminImport

[![Build Status   ][build_badge]][build_link]
[![Coverage Status][coveralls_badge]][coveralls_link]
[![Code Climate   ][codeclimate_badge]][codeclimate_link]
[![Gem Version    ][rubygems_badge]][rubygems_link]
[![License        ][license_badge]][license_link]


The fastest and most efficient CSV import for Active Admin with support for validations, bulk inserts, and encoding handling.

For more about ActiveAdminImport installation and usage, check [Documentation website](http://activeadmin-plugins.github.io/active_admin_import/) and [Wiki pages](https://github.com/activeadmin-plugins/active_admin_import/wiki) for some specific cases and caveats.


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

#### Wiki

[Check various examples](https://github.com/activeadmin-plugins/active_admin_import/wiki)

## Dependencies

Tool                  | Description
--------------------- | -----------
[rchardet]            | Character encoding auto-detection in Ruby. As smart as your browser. Open source.
[activerecord-import] | Powerful library for bulk inserting data using ActiveRecord.

[rchardet]: https://github.com/jmhodges/rchardet
[activerecord-import]: https://github.com/zdennis/activerecord-import

[build_badge]: https://github.com/activeadmin-plugins/active_admin_import/actions/workflows/test.yml/badge.svg
[build_link]: https://github.com/activeadmin-plugins/active_admin_import/actions
[coveralls_badge]: https://coveralls.io/repos/activeadmin-plugins/active_admin_import/badge.svg
[coveralls_link]: https://coveralls.io/github/activeadmin-plugins/active_admin_import
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
