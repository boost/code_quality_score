# frozen_string_literal: true

require_relative "lib/code_quality_score/version"

Gem::Specification.new do |spec|
  spec.name = "code_quality_score"
  spec.version = CodeQualityScore::VERSION
  spec.authors = ["Isabel Anastasiadis"]
  spec.email = ["isabel@boost.co.nz"]

  spec.summary = "Calculates a score based on reek, flay, and flog warnings."
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["source_code_uri"] = "https://github.com/boost/code_quality_score"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", ">= 2.9.0"
  spec.add_dependency "flay", ">= 2.13.0"
  spec.add_dependency "flog", ">= 4.6.5"
  spec.add_dependency "reek", ">= 6.1.1"
  spec.add_dependency "ruby_parser"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
