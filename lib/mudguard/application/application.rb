# frozen_string_literal: true

require_relative "../infrastructure/persistence/policy_file"
require_relative "../infrastructure/persistence/ruby_files"

# Contains methods to check if your project is a bit muddy
module Mudguard
  # API to mudguard
  module Application
    class << self
      def check(project_path, notification)
        policy_file_path = File.expand_path("MudguardFile", project_path)
        policies = Infrastructure::Persistence::PolicyFile.read(policy_file_path)

        policies.check(Infrastructure::Persistence::RubyFiles.all(project_path), notification)
      end
    end
  end
end
