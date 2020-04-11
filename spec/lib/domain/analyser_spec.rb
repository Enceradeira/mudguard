# frozen_string_literal: true

require "spec_helper"
require_relative "../../../spec/stubs/notification"
require "mudguard/domain/analyser"
require "mudguard/domain/texts"

module Mudguard
  module Domain
    RSpec.describe Analyser do
      subject(:analyser) { Analyser.new(policies: policies, notification: notification) }
      describe "#check" do
        subject(:notification) { Mudguard::Stubs::Notification.new }
        subject(:result_and_messages) do
          result = analyser.check(source)
          { result: result, messages: notification.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }
        let(:file) { "./dir/source.rb" }
        let(:source) { Source.new(location: file, code: code) }
        context "when no policies" do
          let(:policies) { [] }
          context "and no dependencies" do
            let(:code) { "module A;end" }
            it { expect(result).to eq(0) }
            it { expect(messages).to be_empty }
          end

          context "and one dependency" do
            let(:code) { "\n\nmodule A;dep=B::C;end" }
            it { expect(result).to eq(1) }
            it "generates message" do
              expect(messages).to match_array(["#{file}:3 #{dependency_not_allowed('A->B::C')}"])
            end
          end
        end

        context "when one policy" do
          let(:policies) { ["A->B"] }
          context "and dependencies are ok" do
            let(:code) { "module A;dep=B::C;dep=B::D;end" }
            it { expect(result).to eq(0) }
            it { expect(messages).to be_empty }
          end

          context "and one dependency is nok" do
            let(:code) { "module A;dep=B::C;dep=C::D;end" }
            it { expect(result).to eq(1) }
            it { expect(messages).to eq(["#{file}:1 #{dependency_not_allowed('A->C::D')}"]) }
          end

          context "and all dependencies are nok" do
            let(:code) { "module A;dep=C::X;dep=D::Y;end" }
            it { expect(result).to eq(2) }
            it "generates messages" do
              problem1 = "#{file}:1 #{dependency_not_allowed('A->C::X')}"
              problem2 = "#{file}:1 #{dependency_not_allowed('A->D::Y')}"
              expect(messages).to match_array([problem1, problem2])
            end
          end
        end

        context "when two policies" do
          let(:policies) { %w[A->B D->E] }
          context "and two dependencies are nok" do
            let(:code) { "module A;dep=D::C;dep2=E::C;end" }
            it { expect(result).to eq(2) }
            it "generates messages" do
              problem1 = "#{file}:1 #{dependency_not_allowed('A->D::C')}"
              problem2 = "#{file}:1 #{dependency_not_allowed('A->E::C')}"
              expect(messages).to match_array([problem1, problem2])
            end
          end
        end

        context "when policy has comment" do
          let(:policies) { ["A->D # a comment"] }
          context "and dependency is ok" do
            let(:code) { "module A;dep=D::C;end" }
            it { expect(result).to eq(0) }
          end
          context "and dependency is nok" do
            let(:code) { "module A;dep=B::C;end" }
            it { expect(result).to eq(1) }
          end
        end
      end
    end
  end
end
