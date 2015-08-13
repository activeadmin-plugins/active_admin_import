# ActiveAdminImport 
[The most fastest and efficient CSV import for Active Admin
with support of validations, bulk inserts and encodings handling](http://activeadmin-plugins.github.io/active_admin_import/)
 


[![Build Status](https://img.shields.io/travis/activeadmin-plugins/active_admin_import.svg)](https://travis-ci.org/activeadmin-pluginsl/active_admin_import)
[![Dependency Status](http://img.shields.io/gemnasium/activeadmin-plugins/active_admin_import.svg)](https://gemnasium.com/activeadmin-plugins/active_admin_import)
[![Coverage Status](https://coveralls.io/repos/activeadmin-plugins/active_admin_import/badge.svg)](https://coveralls.io/r/activeadmin-plugins/active_admin_import)

[![Code Climate](http://img.shields.io/codeclimate/github/activeadmin-plugins/active_admin_import.svg)](https://codeclimate.com/github/activeadmin-plugins/active_admin_import)
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
gem "active_admin_import" , github: "activeadmin-plugins/active_admin_import"

```

And then execute:

    $ bundle


# active_admin_import features
<ol>
  <li> Replacements/Updates support</li>
  <li> Encoding handling</li>
  <li> CSV options</li>
  <li> Ability to describe/change CSV headers</li>
  <li> Bulk import (activerecord-import)</li>
  <li> Callbacks</li>
  <li> Zip files</li>
  <li> and more...</li>
</ol>

   

#### Basic usage

```ruby
ActiveAdmin.register Post
  active_admin_import options
end
```


#### Options
Tool                    | Description
---------------------   | -----------
:back					|resource action to redirect after processing
:csv_options			|hash with column separator, row separator, etc 
:validate				|bool means perform validations or not
:batch_size				|integer value of max  record count inserted by 1 query/transaction
:batch_transaction    |bool, if batch import using transaction, false by default
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



#### Wiki

[Check various examples](https://github.com/activeadmin-plugins/active_admin_import/wiki)

## Dependencies

Tool                  | Description
--------------------- | -----------
[rchardet]            | Character encoding auto-detection in Ruby. As smart as your browser. Open source.
[activerecord-import] | Powerful library for bulk inserting data using ActiveRecord.

[rchardet]: https://github.com/jmhodges/rchardet
[activerecord-import]: https://github.com/zdennis/activerecord-import


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request








