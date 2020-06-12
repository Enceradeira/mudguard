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
        before { File.delete(file_path) if File.exist?(file_path) }

        describe ".read" do
          subject(:file) { PolicyFile.read(project_path) }
          context "when file is empty" do
            before { FileUtils.touch(file_path) }
            it { expect(file).to be_empty }
          end

          context "when file has empty lines" do
            before { File.write(file_path, "\n\n") }
            it { expect(file).to be_empty }
          end

          context "when file has comment lines" do
            before { File.write(file_path, " # This is a line with comment only") }
            it { expect(file).to be_empty }
          end

          context "when file has scope" do
            before { File.write(file_path, "'./**/*.rb':\n - a->b") }
            it { expect(file).to match_array("./**/*.rb" => ["a->b"]) }
          end

          context "when dependency looks like a symbol" do
            before { File.write(file_path, "'*.rb':\n - ::a->::b") }
            it { expect(file).to match_array("*.rb" => ["::a->::b"]) }
          end

          context "when file has empty scope" do
            before { File.write(file_path, "'*.rb':") }
            it { expect(file).to match_array("*.rb" => []) }
          end

          context "when file not exists" do
            it "returns default rules" do
              expect(file).not_to be_empty
            end
            it "creates files" do
              PolicyFile.read(project_path)
              expect(File.exist?(file_path)).to be_truthy
            end
          end

          context "when file contains tabulator" do
            before { File.write(file_path, "\tDependencies:[]") }
            it { expect { PolicyFile.read(project_path) }.to raise_error(Mudguard::Domain::Error) }
          end
        end
      end
    end
  end
end
