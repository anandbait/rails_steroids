# frozen_string_literal: true

module Steroid
  class NewProjectGenerator < Rails::Generators::Base
    desc "Adds New Project to the application"
    source_root File.expand_path("templates", __dir__)

    def add_new_project
      say "Injecting steroid: New Project"
      project_name = ask("What is the great name of your Rails project?")
      project_name_underscored = project_name.underscore
      empty_directory project_name_underscored
      ruby_version = ask("Which Ruby version would you like to use?").strip
      create_file "#{project_name_underscored}/.ruby_version" do
        ruby_version
      end
      run "cd #{project_name_underscored}"
      cmd = ["rails"]
      current_rails_version = `rails --version`.gsub('Rails ', '')
      rails_version = ask("Which Rails version would you like to use? You can find Rails version from https://rubygems.org/gems/rails/versions. Current default version is #{current_rails_version}")
      rails_version = rails_version.present? ? rails_version : current_rails_version
      cmd << "_#{rails_version}_"
      cmd << "new"
      cmd << project_name

      database_name = ask("Choose your database (options: mysql, trilogy, postgresql, sqlite3, oracle, sqlserver, jdbcmysql, jdbcsqlite3, jdbcpostgresql, jdbc)") 
      cmd << "--database #{database_name}"

      asset_pipeline = ask("Choose your asset pipeline (options: sprockets, propshaft)")
      cmd << "--asset-pipeline #{asset_pipeline}"

      css = ask("Choose CSS processor (options: tailwind, bootstrap, bulma, postcss, sass)")
      cmd << "--css #{css}"

      js = ask("Choose JavaScript approach (options: importmap, bun, webpack, esbuild, rollup)")
      cmd << "--javascript #{js}"

      cmd << "--api" if yes?("API only application? (yes/no)")
      cmd << "--skip-jbuilder" if yes?("Skip jbuilder? (yes/no)")
      cmd << "--skip-git" if yes?("Skip git init, .gitignore and .gitattributes? (yes/no)")
      cmd << "--skip-docker" if yes?("Skip Dockerfile, .dockerignore and bin/docker-entrypoint? (yes/no)")
      cmd << "--skip-action-cable" if yes?("Skip Action Cable files? (yes/no)")
      cmd << "--skip-hotwire" if yes?("Skip Hotwire integration? (yes/no)")
      cmd << "--skip-test" if yes?("Skip test files? (yes/no)")
      cmd << "--skip-system-test" if yes?("Skip system test files? (yes/no)")
      cmd << "--no-rc"
      run cmd.join(" ")
    end
  end
end
