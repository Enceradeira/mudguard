# frozen_string_literal: true

require "spec_helper"
require "mudguard/policy_file"
require "mudguard/error"

module Mudguard
  RSpec.describe PolicyFile do
    describe ".read" do
      let(:file_path) { File.expand_path("tmp/MudguardFile") }
      context "when file exists" do
        before { FileUtils.touch(file_path) }

        it { expect(PolicyFile.read(file_path)).to_not be_nil }
      end

      context "when file not exists" do
        before { File.delete(file_path) if File.exist?(file_path) }

        it { expect { PolicyFile.read(file_path) }.to raise_error(Error) }
      end
    end
  end
end
