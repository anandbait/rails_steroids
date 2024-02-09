# frozen_string_literal: true

require 'tty/prompt'

module Steroid
  class ModelGenerator < Rails::Generators::Base
    desc "Adds Model to the application"
    source_root File.expand_path("templates", __dir__)

    def add_model
      say "Applying steroid: Model", [:bold, :magenta]
      cmd = ["rails generate model"]
      prompt = TTY::Prompt.new
      model_name = prompt.ask("\nWhat is the great name of your model?") do |q|
        q.required true
        q.modify :remove
      end
      cmd << model_name

      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]

      columns = []
      while prompt.select("\nWould you like to add model attributes(columns)?", boolean_choices)

        column_name = prompt.ask("Specify name of column:") do |q|
          q.required true
          q.modify :remove
        end

        column_type = prompt.select("Choose type of column:", %w(references integer decimal float boolean binary string text date time datetime primary_key digest token))

        if column_type == 'references'
          column_type = "#{column_type}{polymorphic}" if prompt.select("Polymorphic association?", boolean_choices)
        end
        if %w(integer string text binary).include?(column_type)
          if prompt.select("Set limit?", boolean_choices)
            limit = prompt.ask("Specify limit:") do |q|
              q.required true
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            column_type = "#{column_type}{#{limit}}"
          end
        end
        if column_type == 'decimal'
          if prompt.select("Set precision & scale?", boolean_choices)
            precision = prompt.ask("Specify precision:") do |q|
              q.required true
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            scale = prompt.ask("Specify scale:") do |q|
              q.required true
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            column_type = "'#{column_type}{#{precision},#{scale}}'"
          end
        end

        index_option = nil
        if prompt.select("Add index?", boolean_choices)
          index_option = prompt.select("Unique index?", boolean_choices) ? 'uniq' : 'index'
        end

        columns << [column_name, column_type, index_option].compact.join(':')
      end
      cmd += columns

      cmd << "--no-migration" if prompt.select("\nSkip migration?", boolean_choices)
      cmd << "--no-timestamps" if prompt.select("\nSkip created_at, updated_at timestamps?", boolean_choices)
      cmd << "--no-indexes" if prompt.select("\nSkip indexes?", boolean_choices)

      run cmd.join(" ")
    end
  end
end
