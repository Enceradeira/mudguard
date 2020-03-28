# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mudguard/version"

Gem::Specification.new do |spec|
  spec.name          = "mudguard"
  spec.version       = Mudguard::VERSION
  spec.authors       = ["Jorg Jenni"]
  spec.email         = ["jorg.jenni@jennius.co.uk"]

  spec.summary       = "mudguard helps your ruby project not becoming a "\
                       "'Big ball of mud'"
  spec.homepage      = "https://github.com/Enceradeira/mudguard"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
                     .reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = "mudguard"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "guard", "~> 2.1"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~>0.12"
  spec.add_development_dependency "pry-byebug", "~>3.7"
  spec.add_development_dependency "pry-doc", "~>1.0"
  spec.add_development_dependency "rake", "~>13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop", "~>0.80"

  spec.add_dependency "parser", "~>2.7"
end
