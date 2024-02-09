# frozen_string_literal: true

require 'tty/prompt'

module Steroid
  class ControllerGenerator < Rails::Generators::Base
    desc "Adds Controller to the application"
    source_root File.expand_path("templates", __dir__)

    def add_controller
      say "Applying steroid: Controller", [:bold, :magenta]
      cmd = ["rails generate controller"]
      prompt = TTY::Prompt.new
      controller_name = prompt.ask("\nWhat is the great name of your controller?") do |q|
        q.required true
        q.modify :remove
      end
      cmd << controller_name

      actions = prompt.multi_select("\nChoose actions:", %w(index show new edit create update destroy))
      cmd += actions

      boolean_choices = [{name: "yes", value: true}, {name: "no", value: false}]

      custom_actions = []
      while prompt.select("\nWould you like to add more actions?", boolean_choices)
        custom_actions << prompt.ask("Specify name of action:") do |q|
          q.required true
          q.modify :remove
        end
      end
      cmd += custom_actions

      cmd << "--skip-routes" if prompt.select("\nSkip routes?", boolean_choices)
      cmd << "--no-helper" if prompt.select("\nSkip helper?", boolean_choices)

      run cmd.join(" ")
    end
  end
end
