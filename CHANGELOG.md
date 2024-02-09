## [Unreleased]

## [0.7.1] - 2024-02-09

- Improvement: Formatting to terminal output for all steroids
- Improvement: Formatting of `rails_steroids list` output in table format
- Fix: RailsSteroids Banner display on terminal

## [0.7.0] - 2024-02-08

- Improvement in steroid recipe: migration
  - Create new migration interactively for modify table with
    * add_column, remove_column
    * add_index, remove_index
    * add_remove, remove_reference

## [0.6.0] - 2024-02-07

- New steroid recipe: migration
  - Create new migration interactively for
    * Create table
    * Create join table
    * Drop table

## [0.5.0] - 2024-02-06

- New steroid recipe: model (Create new model interactively)

## [0.4.0] - 2024-02-06

- New steroid recipe: controller (Create new controller interactively)
- Documentation improvement

## [0.3.1] - 2024-02-06

- Improvement in steroid recipe new_project : Code improvement (variable name for boolean_choices)
- Improvement in steroid generator : Add `require 'tty/prompt'` by default

## [0.3.0] - 2024-02-05

- Improvement in steroid recipe new_project : Use of TTY-prompt for better interaction

## [0.2.0] - 2024-02-04

- New steroid recipe: new_project (create new Rails project interactively)

## [0.1.0] - 2024-01-28

- Initial release
- Support for CLI to inject steroid into your application
- Support for steroid generator to prepare new steroid recipe
