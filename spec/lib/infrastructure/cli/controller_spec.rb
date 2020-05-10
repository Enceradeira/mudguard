# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/cli/controller"
require "mudguard/domain/error"
require "mudguard/domain/texts"
require_relative "../../../test_projects/test_projects"
require_relative "../../../stubs/view"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.describe Controller do
        describe "parse" do
          subject(:parser) { Controller.new(view: view) }
          subject(:result_and_messages) do
            result = parser.parse!(argv)
            { result: result, messages: view.messages }
          end
          subject(:result) { result_and_messages[:result] }
          subject(:messages) { result_and_messages[:messages] }
          let(:view) { Mudguard::Stubs::View.new }

          context "when project is analysed" do
            let(:argv) { [project_dir] }
            context "with muddy project" do
              let(:project_dir) { TestProjects::PATH_TO_MUDDY_PROJECT }
              it { expect(result).to be_falsey }
              it "prints results" do
                problem = "./b.rb:6 #{dependency_not_allowed('::B->::A::Klass')}"
                expect(messages).to eq([problem, summary(2, 1)])
              end
            end

            context "with clean project" do
              let(:project_dir) { TestProjects::PATH_TO_CLEAN_PROJECT }
              it { expect(result).to be_truthy }
              it { expect(messages).to eq([summary(2, 0)]) }
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
                it { expect { parser.parse!(argv) }.to raise_error(Mudguard::Domain::Error) }
              end
            end
          end

          context "when help is requested" do
            shared_examples "help writter" do
              it { expect(result).to be_truthy }
              it { expect(messages.length).to eq(1) }
              it { expect(messages.first).to match(/^Usage:.*/) }
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

          context "when print is requested" do
            shared_examples "a dependency printer" do
              it { expect(result).to be_truthy }
              it { expect(messages.length).to be > 1 }
              it { expect(messages.last).to match(/#{dependency_summary(2, 1)}/) }
            end

            context "with -p" do
              let(:argv) { ["-p", TestProjects::PATH_TO_CLEAN_PROJECT] }
              it_behaves_like "a dependency printer"
            end

            context "with --print" do
              let(:argv) { ["--print", TestProjects::PATH_TO_CLEAN_PROJECT] }
              it_behaves_like "a dependency printer"
            end
          end
        end
      end
    end
  end
end
