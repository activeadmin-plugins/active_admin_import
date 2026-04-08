# Changelog
## [6.0.0] - 2026-04-08
- **Breaking:** drop EOL Ruby and Rails versions; require Ruby >= 3.1, Rails >= 7.1, ActiveAdmin >= 3.0, activerecord-import >= 2.0
- Add Rails 8.0 and ActiveAdmin 3.4 / 3.5.1 to the CI matrix
- Add MySQL 8.0 and PostgreSQL 16 jobs alongside the SQLite matrix #213
- Switch JavaScript driver from Poltergeist to Cuprite
- Add `active_admin_import_context` controller convention for injecting request-derived attributes (parent id, current user, request IP, etc.) into every import #211
- Add `:result_class` option for plugging in a custom `ImportResult` subclass (e.g. to capture inserted ids) #214
- Action block is now invoked via `instance_exec` with `result, options` as block arguments (matches `DEFAULT_RESULT_PROC`); zero-arity blocks are unaffected #214
- Fix file caching and format-validation bugs when re-submitting the import form #204
- Move documentation from the (long-stale) wiki and gh-pages site into the README #215
- Replace the dead Coveralls badge with a self-hosted shields.io endpoint badge served from GitHub Pages #216
- Add SimpleCov coverage tracking with a dedicated CI job

## [5.1.0] - 2024-09-19
- Rails 7.0 support #199 | @gigorok
- Fix bugs with cached models #201 | @BigG1947
- Fix `ArgumentError: Number of values (n) exceeds number of columns (m)` #200 | @BigG1947
- Fix error when an empty CSV is passed and the model has `force_encoding: :auto` | @BigG1947
- Migrate from Travis to GitHub Actions

## [5.0.0] - 2021-11-16
- Ruby 3 compatibility added #190  | @clinejj
- Support for a non UTF-8 file when zip uploading #185| @naokirin 
- Rails 6 supported #183 | @pnghai
- Drop ruby 2.4 support #192 | @Fivell


## [4.2.0] - 2020-02-05
- generic exception for import added #175 | @linqueta

## [4.1.2] - 2019-12-16
- allow application/octet-stream content-type #172 | @dmitry-sinina
- Allow activerecord-import >= 0.27 #171 | @sagium 

## [4.1.1] - 2019-09-20
- Fix column slicing #168 | @doredesign
- Handle errors on base #163

## [4.1.0] - 2019-01-15
- Upgrade dependencies: `activerecord-import` to >=0.27.1 | @jkowens

## [4.0.0] - 2018-07-19
- Adde German translation | @morris-frank
- Remove support for Ruby 2.1 and Rails 4

## [3.1.0] - 2018-04-10
- Lower dependency of ActiveAdmin to >= 1.0.0.pre2
- Add possibility to skip columns/values in CSV (batch_slice_columns method)

[Unreleased]: https://github.com/activeadmin-plugins/active_admin_import/compare/v6.0.0...HEAD
[6.0.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v5.1.0...v6.0.0
[5.1.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v4.2.0...v5.0.0
[4.2.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v4.1.2...v4.2.0
[4.1.2]: https://github.com/activeadmin-plugins/active_admin_import/compare/v4.1.1...v4.1.2
[4.1.1]: https://github.com/activeadmin-plugins/active_admin_import/compare/v4.1.0...v4.1.1
[4.1.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/v3.1.0...v4.0.0
[3.1.0]: https://github.com/activeadmin-plugins/active_admin_import/compare/3.0.0...v3.1.0
