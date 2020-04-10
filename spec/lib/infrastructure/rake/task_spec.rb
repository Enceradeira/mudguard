# frozen_string_literal: true

require "spec_helper"
require "rake"
require "mudguard/infrastructure/rake/task"
require "open3"
require_relative "../../../test_projects/test_projects"

module Mudguard
  module Infrastructure
    module Rake
      RSpec.describe Task do
        describe "mudguard" do
          let(:task_script) { File.expand_path("execute_task", __dir__) }
          let(:task_cmd) { "bundler exec #{task_script} #{project}" }
          subject(:return_values) { Open3.capture2(task_cmd) }
          subject(:exit_code) { return_values[1] }
          subject(:std_out) { return_values[0] }

          context "when it's muddy" do
            let(:project) { TestProjects::PATH_TO_MUDDY_PROJECT }
            it { expect(exit_code).not_to be_success }
            it { expect(std_out).to match(/\d+ problem detected/) }
          end

          context "when it's ok" do
            let(:project) { TestProjects::PATH_TO_CLEAN_PROJECT }
            it { expect(exit_code).to be_success }
            it { expect(std_out).to match(/0 problems detected/) }
          end
        end
      end
    end
  end
end
