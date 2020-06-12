# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/cli/controller"
require_relative "controller_context"
require_relative "../../../test_projects/test_projects"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.describe Controller do
        include_context "Controller"
        describe "parse" do
          context "when print is requested" do
            shared_examples "printing dependencies" do
              it { expect(result).to be_truthy }
              it { expect(messages.length).to be > 1 }
              it { expect(messages.last).to match(/#{dependency_summary(3, 2)}/) }
            end

            context "with -p" do
              let(:argv) { ["-p", TestProjects::PATH_TO_CLEAN_PROJECT] }
              it_behaves_like "printing dependencies"
            end

            context "with --print" do
              let(:argv) { ["--print", TestProjects::PATH_TO_CLEAN_PROJECT] }
              it_behaves_like "printing dependencies"
            end
          end

          context "when compressed output" do
            shared_examples "omitting duplicates" do
              it { expect(result).to be_falsey }
              it "prints dependeny only once" do
                expect(messages.select { |m| m =~ /^::B->::A::Klass not allowed$/ }.length)
                  .to eq(1)
              end
            end

            context "with -c" do
              let(:argv) { ["-c", TestProjects::PATH_TO_MUDDY_PROJECT] }
              it_behaves_like "omitting duplicates"
            end

            context "with --compressed" do
              let(:argv) { ["--compressed", TestProjects::PATH_TO_MUDDY_PROJECT] }
              it_behaves_like "omitting duplicates"
            end
          end
        end
      end
    end
  end
end
