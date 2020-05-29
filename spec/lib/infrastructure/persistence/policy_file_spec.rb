# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/persistence/policy_file"
require "mudguard/domain/error"

module Mudguard
  module Infrastructure
    module Persistence
      RSpec.describe PolicyFile do
        let(:project_path) { File.expand_path("policy_file_project", __dir__) }
        let(:file_path) { File.join(project_path, ".mudguard.yml") }
        let(:project_sources) do
          [Domain::Source.new(location: "./test.rb", code_loader: -> { "" })]
        end
        before { File.delete(file_path) if File.exist?(file_path) }

        describe ".read" do
          subject(:scopes) { PolicyFile.read(project_path) }
          context "and file is empty" do
            before { FileUtils.touch(file_path) }
            it { expect(scopes).to be_empty }
          end

          context "when file has empty lines" do
            before { File.write(file_path, "\n\n") }
            it { expect(scopes).to be_empty }
          end

          context "when file has comment lines" do
            before { File.write(file_path, " # This is a line with comment only") }
            it { expect(scopes).to be_empty }
          end

          context "when file has scope" do
            before { File.write(file_path, "'./**/*.rb':\n - a->b") }
            it "returns scope with dependencies" do
              expect(scopes).to match_array([Domain::Scope.new(name: "./**/*.rb",
                                                               sources: project_sources,
                                                               dependencies: ["a->b"])])
            end
          end

          context "when dependency looks like a symbol" do
            before { File.write(file_path, "'*.rb':\n - ::a->::b") }
            it "returns dependencies as string" do
              expect(scopes).to match_array([Domain::Scope.new(name: "*.rb",
                                                               sources: project_sources,
                                                               dependencies: ["::a->::b"])])
            end
          end

          context "when file has empty scope" do
            before { File.write(file_path, "'*.rb':") }
            it "returns dependencies as string" do
              expect(scopes).to match_array([Domain::Scope.new(name: "*.rb",
                                                               sources: project_sources,
                                                               dependencies: [])])
            end
          end
        end

        context "when file not exists" do
          it { expect { PolicyFile.read(project_path) }.to raise_error(Mudguard::Domain::Error) }
        end

        context "when file contains tabulator" do
          before { File.write(file_path, "\tDependencies:[]") }
          it { expect { PolicyFile.read(project_path) }.to raise_error(Mudguard::Domain::Error) }
        end

        context "when file is empty" do
          before { File.write(file_path, "") }
          it { expect(PolicyFile.read(project_path)).to be_empty }
        end
      end
    end
  end
end
