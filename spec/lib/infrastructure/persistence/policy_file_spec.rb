# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/persistence/policy_file"
require "mudguard/domain/error"

module Mudguard
  module Infrastructure
    module Persistence
      RSpec.describe PolicyFile do
        describe ".read" do
          let(:file_path) { File.expand_path("tmp/MudguardFile") }
          before { File.delete(file_path) if File.exist?(file_path) }
          context "when file exists" do
            subject(:policies) { PolicyFile.read(file_path) }
            context "and file is empty" do
              before { FileUtils.touch(file_path) }
              it { expect(policies).to be_empty }
            end

            context "when file has empty lines" do
              before { File.write(file_path, "\n\n") }
              it { expect(policies).to be_empty }
            end

            context "when file has comment lines" do
              before { File.write(file_path, " # This is a line with comment only") }
              it { expect(policies).to be_empty }
            end
          end

          context "when file not exists" do
            it { expect { PolicyFile.read(file_path) }.to raise_error(Mudguard::Domain::Error) }
          end
        end
      end
    end
  end
end
