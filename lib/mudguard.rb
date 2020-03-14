# frozen_string_literal: true

require "mudguard/version"
require_relative "mudguard/policy_file"
require_relative "mudguard/policies"
require_relative "mudguard/ruby_files"

# Contains methods to check if your project is a bit muddy
module Mudguard
  class << self
    def check(project_path)
      policy_file_path = File.expand_path("MudguardFile", project_path)
      policies = PolicyFile.read(policy_file_path)

      files = RubyFiles.all(project_path).map { |f| File.read(f) }

      policies.check(files)
    end
  end
end
