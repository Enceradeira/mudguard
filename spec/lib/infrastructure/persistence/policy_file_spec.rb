# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/persistence/policy_file"
require "mudguard/domain/error"

module Mudguard
  module Infrastructure
    module Persistence
      RSpec.describe PolicyFile do
        subject(:file) { PolicyFile.read(file_path) }
        let(:file_path) { File.expand_path("tmp/.mudguard.yml") }
        before { File.delete(file_path) if File.exist?(file_path) }

        describe "#allowed_dependencies" do
          subject(:allowed_dependencies) { file.allowed_dependencies }
          context "and file is empty" do
            before { FileUtils.touch(file_path) }
            it { expect(allowed_dependencies).to be_empty }
          end

          context "when file has empty lines" do
            before { File.write(file_path, "\n\n") }
            it { expect(allowed_dependencies).to be_empty }
          end

          context "when file has comment lines" do
            before { File.write(file_path, " # This is a line with comment only") }
            it { expect(allowed_dependencies).to be_empty }
          end

          context "when file has dependencies key" do
            before { File.write(file_path, "Dependencies:\n - a->b") }
            it { expect(allowed_dependencies).to match_array(["a->b"]) }
          end

          context "when dependency looks like a symbol" do
            before { File.write(file_path, "Dependencies:\n - ::a->::b") }
            it { expect(allowed_dependencies).to match_array(["::a->::b"]) }
          end
        end

        describe "#excluded_files" do
          subject(:excluded_files) { file.excluded_files }
          context "when file has exclude key" do
            before { File.write(file_path, "Exclude:\n- .\\test\\*.rb") }
            it { expect(excluded_files).to match_array([".\\test\\*.rb"]) }
          end

          context "when file lacks exclude key" do
            before { File.write(file_path, "") }
            it { expect(excluded_files).to be_empty }
          end
        end

        describe ".read" do
          context "when file not exists" do
            it { expect { PolicyFile.read(file_path) }.to raise_error(Mudguard::Domain::Error) }
          end

          context "when file contains tabulator" do
            before { File.write(file_path, "\tDependencies:[]") }
            it { expect { PolicyFile.read(file_path) }.to raise_error(Mudguard::Domain::Error) }
          end

          context "when file is empty" do
            before { File.write(file_path, "") }
            it { expect(PolicyFile.read(file_path)).not_to be_nil }
          end
        end
      end
    end
  end
end
