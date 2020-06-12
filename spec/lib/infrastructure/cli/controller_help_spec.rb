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
          context "when help is requested" do
            shared_examples "printing help" do
              it { expect(result).to be_truthy }
              it { expect(messages.length).to eq(1) }
              it { expect(messages.first).to match(/^Usage:.*/) }
            end

            context "with -h" do
              let(:argv) { ["-h"] }
              it_behaves_like "printing help"
            end

            context "with --help" do
              let(:argv) { ["--help"] }
              it_behaves_like "printing help"
            end

            context "with --help ./project" do
              let(:argv) { ["--help", TestProjects::PATH_TO_MUDDY_PROJECT] }
              it_behaves_like "printing help"
            end
          end
        end
      end
    end
  end
end
