# frozen_string_literal: true

require "spec_helper"
require "mudguard/domain/error"
require_relative "../../test_projects/test_projects"

module Mudguard
  module Application
    RSpec.describe Mudguard::Application do
      subject(:mudguard) { Mudguard::Application }
      let(:notification) { double("notification") }

      describe "#check" do
        subject(:result) { mudguard.check(project, notification) }
        before { allow(notification).to receive(:add) }
        context "when it's muddy" do
          let(:project) { TestProjects::PATH_TO_MUDDY_PROJECT }
          it { is_expected.to be_falsey }
        end

        context "when it's ok" do
          let(:project) { TestProjects::PATH_TO_CLEAN_PROJECT }
          it { is_expected.to be_truthy }
        end

        context "when MudguardFile missing" do
          let(:project) { TestProjects::PATH_TO_EMPTY_DIR }
          it "raises error " do
            expect { mudguard.check(project, notification) }.to raise_error(Mudguard::Domain::Error)
          end
        end

        context "when project can't be parsed" do
          let(:project) { TestProjects::PATH_TO_PROJECT_WITH_INVALID_RUBY }
          it { is_expected.to be_truthy }
        end
      end

      describe "#print_allowed_dependencies" do
        let(:project) { TestProjects::PATH_TO_CLEAN_PROJECT }
        it "prints allowed dependencies" do
          expect(notification).to receive(:add).at_least(:once)
          mudguard.print_allowed_dependencies(project, notification)
        end
      end
    end
  end
end
