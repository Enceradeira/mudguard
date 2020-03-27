# frozen_string_literal: true

require "spec_helper"
require_relative "../../../spec/stubs/notification"

module Mudguard
  module Domain
    RSpec.describe Policies do
      describe "#check" do
        subject(:result_and_messages) do
          notification = Mudguard::Stubs::Notification.new
          result = Policies.new(policies: policies).check(sources, notification)
          {result: result, messages: notification.messages}
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }

        context "when no policies" do
          let(:policies) { [] }
          context "and two sources" do
            let(:sources) { [source1, source2] }
            context "and no dependencies" do
              let(:source1) { "module A;end" }
              let(:source2) { "module B;end" }
              it { expect(result).to be_truthy }
              it { expect(messages).to eq(["2 files inspected, 0 problems detected"]) }
            end

            context "and one dependency in each sources" do
              let(:source1) { "module A;dep=B::C;end" }
              let(:source2) { "module B;dep=D::C;end" }
              it { expect(result).to be_falsey }
              it { expect(messages).to eq(["2 files inspected, 2 problems detected"]) }
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
              it { expect(messages).to eq(["2 files inspected, 0 problems detected"]) }
              it { expect(result).to be_truthy }
            end

            context "and one dependency in one source is nok" do
              let(:source1) { "module B;dep=A::C;end" }
              let(:source2) { "module B;end" }
              it { expect(result).to be_falsey }
              it "generates messages" do
                expect(messages).to eq(["./files/source1.rb:1 B->A::C not allowed",
                                        "2 files inspected, 1 problem detected"])
              end
            end

            context "and one dependency in each source is nok" do
              let(:source1) { "module B;dep=A::C;end" }
              let(:source2) { "module B;dep=B::D;end" }
              it { expect(result).to be_falsey }
              it { expect(messages).to eq(["2 files inspected, 2 problems detected"]) }
            end
          end
        end

        context "when two policies" do
          let(:policies) { %w[A->B D->E] }
          context "and no source" do
            let(:sources) { [] }
            it { expect(result).to be_truthy }
            it { expect(messages).to eq(["0 files inspected, 0 problems detected"]) }
          end
          context "and two dependencies in one source nok" do
            let(:sources) { ["module A;dep=D::C;dep2=E::C;end"] }
            it { expect(result).to be_falsey }
            it { expect(messages).to eq(["1 file inspected, 2 problems detected"]) }
          end
        end
      end
    end
  end
end
