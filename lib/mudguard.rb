# frozen_string_literal: true

require_relative "./mudguard/version"
require_relative "./mudguard/persistence/policy_file"
require_relative "./mudguard/persistence/ruby_files"

# Contains methods to check if your project is a bit muddy
module Mudguard
  class << self
    def check(project_path)
      policy_file_path = File.expand_path("MudguardFile", project_path)
      policies = Persistence::PolicyFile.read(policy_file_path)

      files = Persistence::RubyFiles.all(project_path).map { |f| File.read(f) }

      policies.check(files)
    end
  end
end
