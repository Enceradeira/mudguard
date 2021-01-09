# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/cli/controller"
require "mudguard/domain/error"
require "mudguard/domain/texts"
require_relative "controller_context"
require_relative "../../../test_projects/test_projects"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.describe Controller do
        include_context "Controller"
        describe "parse" do
          context "when project is analysed" do
            let(:argv) { [project_dir] }
            context "with muddy project" do
              let(:project_dir) { TestProjects::PATH_TO_MUDDY_PROJECT }
              it { expect(result).to be_falsey }
              it "prints results" do
                problem1 = "./c.rb:6 #{dependency_not_allowed('::B->::A::Klass')}"
                problem2 = "./b.rb:6 #{dependency_not_allowed('::B->::A::Klass')}"
                expect(messages).to eq([problem1, problem2, summary(3, 2)])
              end
            end

            context "with clean project" do
              let(:project_dir) { TestProjects::PATH_TO_CLEAN_PROJECT }
              it { expect(result).to be_truthy }
              it { expect(messages).to eq([summary(4, 0)]) }
            end

            context "without any arguments" do
              let(:argv) { [] }
              context "and it has a Guardfile in working dir" do
                it "use current Guardfile" do
                  Dir.chdir(TestProjects::PATH_TO_CLEAN_PROJECT) do
                    expect(result).to be_truthy
                  end
                end
              end

              context "and it hasn't got a Guardfile in working dir" do
                let(:mudguard_file) do
                  File.join(TestProjects::PATH_TO_PRJ_WITHOUT_MUDG_FILE, ".mudguard.yml")
                end
                before { File.delete(mudguard_file) if File.exist?(mudguard_file) }

                it "creates Guardfile" do
                  Dir.chdir(TestProjects::PATH_TO_PRJ_WITHOUT_MUDG_FILE) do
                    parser.parse!(argv)
                    expect(File.exist?(mudguard_file))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
