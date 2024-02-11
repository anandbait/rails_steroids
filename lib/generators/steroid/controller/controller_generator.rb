# frozen_string_literal: true

require 'tty/prompt'

module Steroid
  class ControllerGenerator < Rails::Generators::Base
    include RailsSteroids::Base
    desc File.read("#{__dir__}/USAGE")
    source_root File.expand_path("templates", __dir__)

    def help
      if ['-h', 'help', '--help'].include?(ARGV.last)
        puts File.read("#{__dir__}/USAGE")
        exit
      end
    end

    def add_controller
      say "Applying steroid: Controller", [:bold, :magenta]
      cmd = ["rails generate controller"]

      controller_name = prompt.ask("\nWhat is the great name of your controller?", required: true) { |q| q.modify :remove }
      cmd << controller_name

      actions = prompt.multi_select("\nChoose actions:", %w(index show new edit create update destroy))
      cmd += actions

      custom_actions = []
      while prompt.select("\nWould you like to add more actions?", boolean_choices)
        custom_actions << prompt.ask("Specify name of action:", required: true) { |q| q.modify :remove }
      end
      cmd += custom_actions

      cmd << "--skip-routes" if prompt.select("\nSkip routes?", boolean_choices)
      cmd << "--no-helper" if prompt.select("\nSkip helper?", boolean_choices)

      run cmd.join(" ")
    end
  end
end
