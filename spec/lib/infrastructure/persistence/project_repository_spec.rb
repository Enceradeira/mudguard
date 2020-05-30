# frozen_string_literal: true

require "mudguard/infrastructure/persistence/project_repository"
require "mudguard/domain/source_policies"

module Mudguard
  module Infrastructure
    module Persistence
      RSpec.describe ProjectRepository do
        subject(:repository) { ProjectRepository }

        describe "load_source" do
          subject(:source_policies) { repository.load_source_policies(project_path) }
          context "when test project" do
            let(:project_path) { File.expand_path("project_repository_project", __dir__) }
            it "loads each file once" do
              expect(source_policies.length).to eq(4)
            end
            it "loads file0.rb" do
              source = Domain::Source.new(location: "./file0.rb")
              policies = ["Global-Policy"]
              file_policies = Domain::SourcePolicies.new(source: source, policies: policies)
              expect(source_policies).to include(file_policies)
            end
            it "loads file1.rb" do
              source = Domain::Source.new(location: "./subdir1/file1.rb")
              policies = %w[Global-Policy Subdir1-Policy-1 Subdir1-Policy-2]
              file_policies = Domain::SourcePolicies.new(source: source, policies: policies)
              expect(source_policies).to include(file_policies)
            end
            it "loads file2.rb" do
              source = Domain::Source.new(location: "./subdir2/file2.rb")
              policies = %w[Global-Policy Subdir2-Policy]
              file_policies = Domain::SourcePolicies.new(source: source, policies: policies)
              expect(source_policies).to include(file_policies)
            end
            it "loads file3.rb" do
              source = Domain::Source.new(location: "./subdir2/file3.rb")
              policies = %w[Global-Policy Subdir2-Policy]
              file_policies = Domain::SourcePolicies.new(source: source, policies: policies)
              expect(source_policies).to include(file_policies)
            end
          end
        end
      end
    end
  end
end
