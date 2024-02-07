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
      prompt = TTY::Prompt.new
      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]

      action_choices = [
        {name: 'Create table', value: 'create_table'},
        {name: 'Create join table', value: 'create_join_table'},
        {name: 'Drop table', value: 'drop_table'},
        # {name: 'Modify table columns/index', value: 'modify_table'},
        # {name: 'Add column', value: 'add_column'},
        # {name: 'Remove column', value: 'remove_column'},
        # {name: 'Add index', value: 'add_index'},
        # {name: 'Remove index', value: 'remove_index'},
      ]
      action = prompt.select("What would you like to do?", action_choices)

      case action
      when 'create_table'
        table_name = prompt.ask("What is the name of table to be created?", required: true) { |q| q.modify :remove }
        @content = content_for_create_table(table_name, collect_columns_data, need_timestamps?)
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
          columns_data << {name: "[:#{table2_name.singularize}_id, :#{table2_name.singularize}_id]", type: 'index'}.merge(uniq_index_option)
        end
        @content = content_for_create_join_table(table1_name, table2_name, table_name, (columns_data + collect_columns_data), need_timestamps?)
        migration_template "migration.rb", "#{db_migrate_path}/create_join_table_#{table_name}.rb"
      when 'drop_table'
        table_name = prompt.ask("What is the name of table to be dropped?", required: true) { |q| q.modify :remove }
        @content = content_for_drop_table(table_name)
        migration_template "migration.rb", "#{db_migrate_path}/drop_#{table_name}.rb"
      # when 'modify_table'
      #   table_name = prompt.ask("What is the name of table to add/remove columns?", required: true) { |q| q.modify :remove }
      #   columns_to_be_added = collect_columns_data
      #   columns_to_be_removed
      #   migration_template "migration.rb", "#{db_migrate_path}/drop_#{table_name}.rb"
      # when 'add_column'
      # when 'remove_column'
      # when 'add_index'
      # when 'remove_index'
      end
    end

    private

    def collect_columns_data
      prompt = TTY::Prompt.new
      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]
      columns = []
      while prompt.select("Would you like to add model attributes(columns)?", boolean_choices)
        columns_data = { meta: {} }
        column_name = prompt.ask("Specify name of column:", required: true) { |q| q.modify :remove }

        column_type = prompt.select("Choose type of column:", %w(references boolean string text integer decimal float binary date time datetime primary_key digest token))

        if column_type == 'references'
          columns_data[:meta][:polymorphic] = true if prompt.select("Polymorphic association?", boolean_choices)
        end
        if %w(integer string text binary).include?(column_type)
          if prompt.select("Set limit?", boolean_choices)
            limit = prompt.ask("Specify limit:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            columns_data[:meta][:limit] = limit
          end
        end
        if column_type == 'decimal'
          if prompt.select("Set precision & scale?", boolean_choices)
            precision = prompt.ask("Specify precision:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            columns_data[:meta][:precision] = precision
            scale = prompt.ask("Specify scale:", required: true) do |q|
              q.modify :remove
              q.convert(:int, "Invalid input! Please provide integer value.")
            end
            columns_data[:meta][:scale] = scale
          end
        end

        if %w(references primary_key digest token).exclude?(column_type) && prompt.select("Add default value?", boolean_choices)
          acceptable_value_type = { 'text' => :string }[column_type] || column_type.to_sym
          columns_data[:meta][:default] = prompt.ask("Specify default value:", required: true) do |q|
            q.modify :remove
            q.convert(acceptable_value_type, "Invalid input! Please provide %{type} value.")
          end
        end

        if prompt.select("Add index?", boolean_choices)
          columns_data[:meta][:index] = prompt.select("Unique index?", boolean_choices) ? :unique : true
        end

        columns_data.merge!(name: column_name, type: column_type)
        columns << columns_data
      end
      columns
    end

    def need_timestamps?
      prompt = TTY::Prompt.new
      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]
      prompt.select("Add timestamps?", boolean_choices)
    end

    def content_for_create_table(table_name, columns_data, need_timestamps)
      columns_data_content = columns_data.map do |c|
        column_row = ["t.#{c[:type]} :#{c[:name]}"]
        c[:meta].each { |key, value| column_row << "#{key}: #{value.inspect}" }
        column_row.join(', ')
      end
      columns_data_content << "t.timestamps" if need_timestamps
      <<-CONTENT
  def change
    create_table :#{table_name}#{primary_key_type} do |t|
      #{columns_data_content.join("\n      ")}
    end
  end
      CONTENT
    end

    def content_for_create_join_table(table1_name, table2_name, table_name, columns_data, need_timestamps)
      columns_data_content = columns_data.map do |c|
        column_row = ["t.#{c[:type]} :#{c[:name]}"]
        c[:meta]&.each { |key, value| column_row << "#{key}: #{value.inspect}" }
        column_row.join(', ')
      end
      columns_data_content << "t.timestamps" if need_timestamps
      <<-CONTENT
  def change
    create_join_table :#{table1_name}, :#{table2_name}, table_name: :#{table_name} do |t|
      #{columns_data_content.join("\n      ")}
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

  end
end
