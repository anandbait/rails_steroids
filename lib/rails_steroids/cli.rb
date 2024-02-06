# frozen_string_literal: true

require "rails/generators"
require "thor"
require_relative "../rails_steroids"

module RailsSteroids
  class CLI < Thor
    map %w(--version -v) => :version

    desc "inject STEROID [options]", "Add steroid into the application"
    def inject(generator, *options)
      require_relative generator_file_path(generator)
      Rails::Generators.invoke(generator, options)
    end

    desc "prepare STEROID", "Scaffolds steroid template for developing a new steroid recipe"
    def prepare(steroid)
      Rails::Generators.invoke('steroid', [steroid])
    end

    desc "list", "Print list of steroids"
    def list
      puts "RailsSteroids list"
      puts "| Functionality | Command |"
      puts "|---|---|"
      steroid_names = [
        'model',
        'controller',
        'new_project',
      ]
      steroid_names.each do |steroid|
        puts "|#{steroid.titlecase}|`rails_steroids inject steroid:#{steroid}`|"
      end
      # TODO: Glob all file and prepare a list of available generators
    end

    desc "--version, -v", "Print gem version"
    def version
      puts "RailsSteroids v#{RailsSteroids::VERSION}"
    end

    def self.exit_on_failure?
      true
    end

    private

    def generator_file_path(generator)
      namespace, generator_name = generator.split(':')
      raise "Invalid steroid!" if namespace != 'steroid'
      "../generators/steroid/#{generator_name}/#{generator_name}_generator.rb"
    end
  end
end