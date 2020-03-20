# frozen_string_literal: true

require "open3"
require "spec_helper"
require_relative "../test_projects/test_projects"

module Mudguard
  RSpec.describe "mudguard-exe" do
    subject(:mudguard_exe) { "../../../exe/mudguard #{args}" }
    subject(:return_values) { Open3.capture2(File.expand_path(mudguard_exe, __FILE__)) }
    subject(:exit_code) { return_values[1] }
    subject(:std_out) { return_values[0] }

    context "when project is analysed" do
      let(:args) { project_dir }
      context "with muddy project" do
        let(:project_dir) { TestProjects::PATH_TO_MUDDY_PROJECT }
        it { expect(exit_code).not_to be_success }
      end

      context "with clean project" do
        let(:project_dir) { TestProjects::PATH_TO_CLEAN_PROJECT }
        it { expect(exit_code).to be_success }
      end
    end

    context "when help is requested" do
      context "with -h" do
        let(:args) { "-h" }
        it { expect(std_out).to match(/^Usage:.*/) }
        it { expect(exit_code).to be_success }
      end
    end
  end
end
