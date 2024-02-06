# frozen_string_literal: true

require 'tty/prompt'

module Steroid
  class NewProjectGenerator < Rails::Generators::Base
    desc "Adds New Project to the application"
    source_root File.expand_path("templates", __dir__)

    def add_new_project
      say "Injecting steroid: New Project"
      prompt = TTY::Prompt.new
      project_name = prompt.ask("What is the great name of your Rails project?") do |q|
        q.required true
        q.modify :remove
      end
      empty_directory project_name

      ruby_version = prompt.ask("Which Ruby version would you like to use?") do |q|
        q.required true
        q.modify :remove
      end
      create_file "#{project_name}/.ruby-version" do
        ruby_version
      end

      cmd = ["rails"]
      current_rails_version = `rails --version`.gsub('Rails ', '').strip
      rails_version = prompt.ask("Which Rails version would you like to use? You can find Rails version from https://rubygems.org/gems/rails/versions.", default: current_rails_version)
      cmd << "_#{rails_version}_"
      cmd << "new"
      cmd << project_name

      database_options = %w(mysql trilogy postgresql sqlite3 oracle sqlserver jdbcmysql jdbcsqlite3 jdbcpostgresql jdbc)
      database_name = prompt.select("Choose your database:", database_options) 
      cmd << "--database #{database_name}"

      asset_pipeline = prompt.select("Choose your asset pipeline:", %w(sprockets propshaft))
      cmd << "--asset-pipeline #{asset_pipeline}"

      css = prompt.select("Choose CSS processor:", %w(tailwind bootstrap bulma postcss sass))
      cmd << "--css #{css}"

      js = prompt.select("Choose JavaScript approach:", %w(importmap bun webpack esbuild rollup))
      cmd << "--javascript #{js}"

      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]
      cmd << "--api" if prompt.select("API only application?", boolean_choices)
      cmd << "--skip-jbuilder" if prompt.select("Skip jbuilder?", boolean_choices)
      cmd << "--skip-git" if prompt.select("Skip git init, .gitignore and .gitattributes?", boolean_choices)
      cmd << "--skip-docker" if prompt.select("Skip Dockerfile, .dockerignore and bin/docker-entrypoint?", boolean_choices)
      cmd << "--skip-action-cable" if prompt.select("Skip Action Cable files?", boolean_choices)
      cmd << "--skip-hotwire" if prompt.select("Skip Hotwire integration?", boolean_choices)
      cmd << "--skip-test" if prompt.select("Skip test files?", boolean_choices)
      cmd << "--skip-system-test" if prompt.select("Skip system test files?", boolean_choices)
      cmd << "--no-rc" # To skip configurations from .railsrc
      cmd << "--skip" # To skip overriding existing files
      run cmd.join(" ")
    end
  end
end
