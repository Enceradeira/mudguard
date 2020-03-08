# frozen_string_literal: true

require "spec_helper"
require_relative "test_projects/test_projects"

module Mudguard
  RSpec.describe Mudguard do
    subject(:mudguard) { Mudguard }
    describe "VERSION" do
      it { expect(mudguard::VERSION).not_to be nil }
    end

    describe "check" do
      subject(:result) { mudguard.check(project) }
      context "when it's muddy" do
        let(:project) { TestProjects::PATH_TO_MUDDY_PROJECT}
        it { is_expected.to be_falsey }
      end
      context "when it's ok" do
        let(:project) { TestProjects::PATH_TO_CLEAN_PROJECT}
        it { is_expected.to be_truthy }
      end
    end
  end
end