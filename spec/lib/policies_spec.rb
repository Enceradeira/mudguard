# frozen_string_literal: true

require "spec_helper"

module Mudguard
  RSpec.describe Policies do
    describe "#check" do
      subject(:result) { Policies.new(policies: policies).check([source]) }

      context "when no policies" do
        let(:policies) { [] }
        context "when ruby source has no dependencies" do
          let(:source) { "module A;end" }
          it { is_expected.to be_truthy }
        end

        context "when ruby source has dependencies" do
          let(:source) { "module A;dep=B::C;end" }
          it { is_expected.to be_falsey }
        end
      end

      context "when one policy" do
        let(:policies) { ["A->B"] }
        context "when ruby source is ok" do
          let(:source) { "module A;dep=B::C;end" }
          it { is_expected.to be_truthy }
        end

        context "when ruby source is nok" do
          let(:source) { "module B;dep=A::C;end" }
          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
