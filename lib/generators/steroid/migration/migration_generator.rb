# frozen_string_literal: true

require 'tty/prompt'
require 'rails/version'
require 'rails/generators/active_record'
require 'rails/generators/active_record/migration'

module Steroid
  class MigrationGenerator < Rails::Generators::Base
    desc "Adds Migration to the application"
    source_root File.expand_path("templates", __dir__)
    include ActiveRecord::Generators::Migration
    include ActiveRecord::Migration::JoinTable

    def add_migration
      say "Injecting steroid: Migration", :green
      cmd = ["rails generate migration"]

      action_choices = [
        {name: 'Create table', value: 'create_table'},
        {name: 'Create join table', value: 'create_join_table'},
        {name: 'Drop table', value: 'drop_table'},
        {name: 'Modify table columns/index', value: 'modify_table'},
      ]
      @action = prompt.select("What would you like to do?", action_choices)

      case @action
      when 'create_table'
        table_name = prompt.ask("What is the name of table to be created?", required: true) { |q| q.modify :remove }
        @content = content_for_create_table(table_name, collect_columns_data)
        migration_template "migration.rb", "#{db_migrate_path}/create_#{table_name}.rb"
      when 'create_join_table'
        table1_name = prompt.ask("What is the name of first table to be joined?", required: true) { |q| q.modify :remove }
        table2_name = prompt.ask("What is the name of second table to be joined?", required: true) { |q| q.modify :remove }
        table_name = prompt.ask("What is the custom name for join table?", default: find_join_table_name(table1_name, table2_name), required: true) { |q| q.modify :remove }
        columns_data = []
        if prompt.select("Add `id` column?", boolean_choices)
          columns_data << {name: 'id', type: 'primary_key'}
        end
        if prompt.select("Add index for #{table1_name} foreign_key?", boolean_choices)
          columns_data << {name: "#{table1_name.singularize}_id", type: 'index'}
        end
        if prompt.select("Add index for #{table2_name} foreign_key?", boolean_choices)
          columns_data << {name: "#{table2_name.singularize}_id", type: 'index'}
        end
        if prompt.select("Add composite index for #{table1_name} and #{table2_name} foreign_key?", boolean_choices)
          uniq_index_option = prompt.select("Unique combination index?", boolean_choices) ? {meta: {unique: true}} : {}
          columns_data << {name: ["#{table2_name.singularize}_id", "#{table2_name.singularize}_id"], type: 'index'}.merge(uniq_index_option)
        end
        @content = content_for_create_join_table(table1_name, table2_name, table_name, (columns_data + collect_columns_data))
        migration_template "migration.rb", "#{db_migrate_path}/create_join_table_#{table_name}.rb"
      when 'drop_table'
        table_name = prompt.ask("What is the name of table to be dropped?", required: true) { |q| q.modify :remove }
        @content = content_for_drop_table(table_name)
        migration_template "migration.rb", "#{db_migrate_path}/drop_#{table_name}.rb"
      when 'modify_table'
        table_name = prompt.ask("What is the name of table to add/remove columns/index?", required: true) { |q| q.modify :remove }
        modify_table_choices = [
          {name: 'Add column', value: 'add_column'}, {name: 'Remove column', value: 'remove_column'},
          {name: 'Add index', value: 'add_index'}, {name: 'Remove index', value: 'remove_index'},
          {name: 'Add reference', value: 'add_reference'}, {name: 'Remove reference', value: 'remove_reference'},
          # {name: 'Add timestamps', value: 'add_timestamps'}, {name: 'Remove timestamps', value: 'remove_timestamps'},
          {name: 'Exit', value: 'exit'}
        ]
        @content = []
        file_name = []
        while (modify_table_action = prompt.select("What would you like to do?", modify_table_choices)) != 'exit'
          for_removal = modify_table_action.start_with?('remove_')
          if modify_table_action.end_with?('_index') || modify_table_action.end_with?('_reference')
            data = modify_table_action.end_with?('_index') ? ask_index_data(for_removal: for_removal) : ask_reference_data(for_removal: for_removal)
            file_name << modify_table_action << data[:name]
          else
            data = ask_column_data(for_removal: for_removal)
            file_name << (for_removal ? 'remove' : 'add') << data[:name]
          end
          @content << format_statement_for_modify_table(modify_table_action, table_name, data)
        end
        @content = content_for_modify_table(@content.join("\n    "))
        migration_template "migration.rb", "#{db_migrate_path}/#{file_name.join('_')}_in_#{table_name}.rb"
      end
    end

    private

    def prompt
      TTY::Prompt.new
    end

    def boolean_choices
      [{name: "yes", value: true}, {name: "no", value: false}]
    end

    def collect_columns_data
      columns_data = []
      while prompt.select("Would you like to add model attributes(columns)?", boolean_choices)
        columns_data << ask_column_data
      end
      timestamps_data = ask_timestamps_data
      columns_data << timestamps_data if timestamps_data
      columns_data
    end

    def ask_column_data(for_removal: false)
      column_data = { meta: {} }
      column_name = prompt.ask("Specify name of column:", required: true) { |q| q.modify :remove }

      column_type_choices = %w(boolean string text integer decimal float binary date time datetime primary_key digest token)
      column_type_choices << 'references' unless @action == 'modify_table'
      column_type = prompt.select("Choose type of column:", column_type_choices)

      if column_type == 'references'
        column_data[:meta][:foreign_key] = true if prompt.select("Foreign_key to be #{for_removal ? 'removed' : 'added'}?", boolean_choices)
        column_data[:meta][:polymorphic] = true if prompt.select("Polymorphic association?", boolean_choices)
      end
      unless for_removal
        if %w(integer string text binary).include?(column_type)
          if prompt.select("Set limit?", boolean_choices)
            limit = prompt.ask("Specify limit:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            column_data[:meta][:limit] = limit
          end
        end
        if column_type == 'decimal'
          if prompt.select("Set precision & scale?", boolean_choices)
            precision = prompt.ask("Specify precision:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            column_data[:meta][:precision] = precision
            scale = prompt.ask("Specify scale:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            column_data[:meta][:scale] = scale
          end
        end

        if %w(references primary_key digest token).exclude?(column_type) && prompt.select("Add default value?", boolean_choices)
          acceptable_value_type = { 'text' => :string }[column_type] || column_type.to_sym
          column_data[:meta][:default] = prompt.ask("Specify default value:", required: true) do |q|
            q.modify :remove
            q.convert(acceptable_value_type, "Invalid input! Please provide %{type} value.")
          end
        end

        if prompt.select("Add index?", boolean_choices)
          column_data[:meta][:index] = prompt.select("Unique index?", boolean_choices) ? :unique : true
        end
      end

      column_data.merge!(name: column_name, type: column_type)
      column_data
    end

    def ask_reference_data(for_removal: false)
      column_data = { meta: {} }
      column_data[:name] = prompt.ask("Specify name of reference:", required: true) { |q| q.modify :remove }
      column_data[:meta][:foreign_key] = true if prompt.select("Foreign_key to be #{for_removal ? 'removed' : 'added'}?", boolean_choices)
      column_data[:meta][:polymorphic] = true if prompt.select("Polymorphic association?", boolean_choices)
      column_data
    end

    def ask_index_data(for_removal: false)
      column_data = { meta: {} }
      names = []
      names << prompt.ask("Specify name of column:", required: true) { |q| q.modify :remove }
      while prompt.select("Add more columns for Composite index?", boolean_choices)
        names << prompt.ask("Specify name of another column:", required: true) { |q| q.modify :remove }
      end
      column_data[:name] = names
      unless for_removal
        column_data[:meta][:unique] = true if prompt.select("Unique index?", boolean_choices)
      end
      custom_name = prompt.ask("Specify custom name for index (optional):") { |q| q.modify :remove }
      column_data[:meta][:name] = custom_name if custom_name.present?
      column_data
    end

    def ask_timestamps_data
      if prompt.select("Add timestamps?", boolean_choices)
        { type: 'timestamps' }
      end
    end

    def format_statement_for_modify_table(modify_table_action, table_name, column_data)
      statement_data = ["#{modify_table_action} :#{table_name}"]
      statement_data << if column_data[:name].is_a?(Array)
        col_name = column_data[:name].size > 1 ? "[#{column_data[:name].map { |n| ":#{n}" }.join(', ')}]" : ":#{column_data[:name].first}"
        "column: #{col_name}" if modify_table_action == 'remove_index'
      else
        ":#{column_data[:name]}"
      end
      statement_data << ":#{column_data[:type]}" if column_data[:type]
      column_data[:meta].each { |key, value| statement_data << "#{key}: #{value.inspect}" }
      statement_data = statement_data.join(', ')
    end

    def format_statement_for_create_table(columns_data)
      columns_data.map do |c|
        column_row = if c[:name].is_a?(Array)
          ["t.#{c[:type]} [#{c[:name].map { |n| ":#{n}" }.join(', ')}]"]
        elsif c[:name].nil?
          ["t.#{c[:type]}"]
        else
          ["t.#{c[:type]} :#{c[:name]}"]
        end
        c[:meta].each { |key, value| column_row << "#{key}: #{value.inspect}" } if c[:meta]
        column_row.join(', ')
      end.join("\n      ")
    end

    def content_for_create_table(table_name, columns_data)
      columns_data_content = format_statement_for_create_table(columns_data)
      <<-CONTENT
  def change
    create_table :#{table_name}#{primary_key_type} do |t|
      #{columns_data_content}
    end
  end
      CONTENT
    end

    def content_for_create_join_table(table1_name, table2_name, table_name, columns_data)
      columns_data_content = format_statement_for_create_table(columns_data)
      <<-CONTENT
  def change
    create_join_table :#{table1_name}, :#{table2_name}, table_name: :#{table_name} do |t|
      #{columns_data_content}
    end
  end
      CONTENT
    end

    def content_for_drop_table(table_name)
      <<-CONTENT
  def change
    drop_table :#{table_name}
  end
      CONTENT
    end

    def content_for_modify_table(statements)
      <<-CONTENT
  def change
    #{statements}
  end
      CONTENT
    end

  end
end
