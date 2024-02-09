class SteroidGenerator < Rails::Generators::NamedBase

  def create_steroid_generator_file
    say "Preparing steroid for #{name.titlecase}", :green
    create_file "lib/generators/steroid/#{name}/#{name}_generator.rb", <<~RUBY
      # frozen_string_literal: true

      require 'tty/prompt'

      module Steroid
        class #{name.camelize}Generator < Rails::Generators::Base
          desc "Adds #{name.titlecase} to the application"
          source_root File.expand_path("templates", __dir__)

          def add_#{name}
            say "Applying steroid: #{name.titlecase}", [:bold, :magenta]
            # Add your other code here or any additional methods below this method
          end
        end
      end
    RUBY
  end

  def create_steroid_templates_directory
    empty_directory("lib/generators/steroid/#{name}/templates")
  end

  def create_usage_file
    create_file "lib/generators/steroid/#{name}/USAGE", <<~RUBY
      Description:
          `steroid:#{name}` will inject #{name.titlecase} functionality interactively.

      Usage Example:
          # with installed gem
          rails_steroids inject steroid:#{name}
          # with bundler
          bin/rails g steroid:#{name}

      What will this do?:
          what/will/it/create
    RUBY
  end

  def create_entry_in_steroids_list
    insert_into_file 'lib/rails_steroids/cli.rb', "  '#{name}',\n      ", after: "steroid_names = [\n      "
    insert_into_file 'README.md', "|#{name}|`rails_steroids inject steroid:#{name}`|\n", after: "|---|---|\n"
  end

end
