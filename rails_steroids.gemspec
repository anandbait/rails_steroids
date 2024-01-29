# frozen_string_literal: true

require_relative "lib/rails_steroids/version"

Gem::Specification.new do |spec|
  spec.name = "rails_steroids"
  spec.version = RailsSteroids::VERSION
  spec.authors = ["Anand Bait"]
  spec.email = ["anandbait@gmail.com"]

  spec.summary = "This gem provides some commands to quickly implement regularly used features."
  spec.description = "This gem will be like steroids taken by athletes. It provides some commands to quickly implement regularly used features to boost your productivity and speed of development."
  spec.homepage = "https://github.com/anandbait/rails_steroids"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/anandbait/rails_steroids"
  spec.metadata["changelog_uri"] = "https://github.com/anandbait/rails_steroids/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[test/ spec/ features/ .git])
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "railties"
  spec.add_dependency "thor"
  spec.add_dependency "rails"


  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"

  spec.post_install_message = "Feel High! Feel powered!! You are on RAILS-STEROIDS!!!"
end
