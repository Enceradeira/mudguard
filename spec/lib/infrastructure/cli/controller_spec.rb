# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/cli/controller"
require "mudguard/domain/error"
require_relative "../../../test_projects/test_projects"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.describe Controller do
        describe "parse" do
          subject(:parser) { Controller.new(view: view) }
          subject(:result) { parser.parse!(argv) }
          subject(:std_out) { return_values[0] }

          let(:view) { double("view") }

          context "when project is analysed" do
            let(:argv) { [project_dir] }
            context "with muddy project" do
              let(:project_dir) { TestProjects::PATH_TO_MUDDY_PROJECT }
              before do
                expect(view).to receive(:print).with(/2 files inspected, 1 problem detected/)
              end
              it { expect(result).to be_falsey }
            end

            context "with clean project" do
              let(:project_dir) { TestProjects::PATH_TO_CLEAN_PROJECT }
              before do
                expect(view).to receive(:print).with(/2 files inspected, 0 problems detected/)
              end
              it { expect(result).to be_truthy }
            end

            context "without any arguments" do
              let(:argv) { [] }
              context "and it has a Guardfile in working dir" do
                before do
                  expect(view).to receive(:print).with(/2 files inspected, 0 problems detected/)
                end
                it "use current Guardfile" do
                  Dir.chdir(TestProjects::PATH_TO_CLEAN_PROJECT) do
                    expect(result).to be_truthy
                  end
                end
              end

              context "and it hasn't got a Guardfile in working dir" do
                it { expect { parser.parse!(argv) }.to raise_error(Mudguard::Domain::Error) }
              end
            end
          end

          context "when help is requested" do
            shared_examples "help writter" do
              before { expect(view).to receive(:print).with(/^Usage:.*/) }
              it { expect(result).to be_truthy }
            end

            context "with -h" do
              let(:argv) { ["-h"] }
              it_behaves_like "help writter"
            end

            context "with --help" do
              let(:argv) { ["--help"] }
              it_behaves_like "help writter"
            end

            context "with --help ./project" do
              let(:argv) { ["--help", TestProjects::PATH_TO_MUDDY_PROJECT] }
              it_behaves_like "help writter"
            end
          end
        end
      end
    end
  end
end