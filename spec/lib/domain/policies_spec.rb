# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Policies do
      describe "#check" do
        subject(:result) { Policies.new(policies: policies).check(sources, notification) }
        let(:notification) { double("notification") }

        context "when no policies" do
          let(:policies) { [] }
          context "and two sources" do
            let(:sources) { [source1, source2] }
            context "and no dependencies" do
              let(:source1) { "module A;end" }
              let(:source2) { "module B;end" }
              before do
                expect(notification).to receive(:add).with("2 files inspected, 0 problems detected")
              end
              it { is_expected.to be_truthy }
            end

            context "and one dependency in each sources" do
              let(:source1) { "module A;dep=B::C;end" }
              let(:source2) { "module B;dep=D::C;end" }
              before do
                expect(notification).to receive(:add).with("2 files inspected, 2 problems detected")
              end
              it { is_expected.to be_falsey }
            end
          end
        end

        context "when one policy" do
          let(:policies) { ["A->B"] }
          context "and two sources" do
            let(:sources) { [source1, source2] }
            context "and all dependencies are ok" do
              let(:source1) { "module A;dep=B::C;end" }
              let(:source2) { "module A;dep=B::D;end" }
              before do
                expect(notification).to receive(:add).with("2 files inspected, 0 problems detected")
              end
              it { is_expected.to be_truthy }
            end

            context "and one dependency in one source is nok" do
              let(:source1) { "module B;dep=A::C;end" }
              let(:source2) { "module B;end" }
              before do
                expect(notification).to receive(:add).with("2 files inspected, 1 problem detected")
              end
              it { is_expected.to be_falsey }
            end

            context "and one dependency in each source is nok" do
              let(:source1) { "module B;dep=A::C;end" }
              let(:source2) { "module B;dep=B::D;end" }
              before do
                expect(notification).to receive(:add).with("2 files inspected, 2 problems detected")
              end
              it { is_expected.to be_falsey }
            end
          end
        end

        context "when two policies" do
          let(:policies) { %w[A->B D->E] }
          context "and no source" do
            let(:sources) { [] }
            before do
              expect(notification).to receive(:add).with("0 files inspected, 0 problems detected")
            end
            it { is_expected.to be_truthy }
          end
          context "and two dependencies in one source nok" do
            let(:sources) { ["module A;dep=D::C;dep2=E::C;end"] }
            before do
              expect(notification).to receive(:add).with("1 file inspected, 2 problems detected")
            end
            it { is_expected.to be_falsey }
          end
        end
      end
    end
  end
end
