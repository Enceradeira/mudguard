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
          { result: result, messages: notification.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }

        context "when no policies" do
          let(:policies) { [] }
          context "and two sources" do
            let(:sources) { [source1, source2] }
            let(:file1) { "./dir/source1.rb" }
            let(:source1) { Source.new(location: file1, code: code1) }
            let(:file2) { "./dir/source2.rb" }
            let(:source2) { Source.new(location: file2, code: code2) }
            context "and no dependencies" do
              let(:code1) { "module A;end" }
              let(:code2) { "module B;end" }
              it { expect(result).to be_truthy }
              it { expect(messages).to eq(["2 files inspected, 0 problems detected"]) }
            end

            context "and one dependency in each sources" do
              let(:code1) { "\n\nmodule A;dep=B::C;end" }
              let(:code2) { "module B;dep=D::C;end" }
              it { expect(result).to be_falsey }
              it "generates messages" do
                problem1 = "#{file1}:3 A->B::C not allowed"
                problem2 = "#{file2}:1 B->D::C not allowed"
                summary = "2 files inspected, 2 problems detected"
                expect(messages).to match_array([problem1, problem2, summary])
              end
            end
          end
        end

        context "when one policy" do
          let(:policies) { ["A->B"] }
          context "and two sources" do
            let(:sources) { [source1, source2] }
            let(:file1) { "./files/source1.rb" }
            let(:source1) { Source.new(location: file1, code: code1) }
            let(:file2) { "./root.rb" }
            let(:source2) { Source.new(location: file2, code: code2) }
            context "and all dependencies are ok" do
              let(:code1) { "module A;dep=B::C;end" }
              let(:code2) { "module A;dep=B::D;end" }
              it { expect(messages).to eq(["2 files inspected, 0 problems detected"]) }
              it { expect(result).to be_truthy }
            end

            context "and one dependency in one source is nok" do
              let(:code1) { "module B;dep=A::C;end" }
              let(:code2) { "module B;end" }
              it { expect(result).to be_falsey }
              it "generates messages" do
                detail_desc = "#{file1}:1 B->A::C not allowed"
                summary = "2 files inspected, 1 problem detected"
                expect(messages).to eq([detail_desc, summary])
              end
            end

            context "and one dependency in each source is nok" do
              let(:code1) { "module B;dep=A::C;end" }
              let(:code2) { "module B;dep=B::D;end" }
              it { expect(result).to be_falsey }
              it "generates messages" do
                problem1 = "#{file1}:1 B->A::C not allowed"
                problem2 = "#{file2}:1 B->B::D not allowed"
                summary = "2 files inspected, 2 problems detected"
                expect(messages).to match_array([problem1, problem2, summary])
              end
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
            let(:file) { "/home/user/prj/source.rb" }
            let(:sources) { [Source.new(location: file, code: "module A;dep=D::C;dep2=E::C;end")] }
            it { expect(result).to be_falsey }
            it "generates messages" do
              problem1 = "#{file}:1 A->D::C not allowed"
              problem2 = "#{file}:1 A->E::C not allowed"
              summary = "1 file inspected, 2 problems detected"
              expect(messages).to match_array([problem1, problem2, summary])
            end
          end
        end

        context "when policy has comment" do
          let(:policies) { ["A->D # a comment"] }
          context "and dependency is ok" do
            let(:sources) { [Source.new(code: "module A;dep=D::C;end")] }
            it { expect(result).to be_truthy }
          end
          context "and dependency is nok" do
            let(:sources) { [Source.new(code: "module A;dep=B::C;end")] }
            it { expect(result).to be_falsey }
          end
        end
      end
    end
  end
end
