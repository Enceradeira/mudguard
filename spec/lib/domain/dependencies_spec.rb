# frozen_string_literal: true

require "spec_helper"
require_relative "../../../spec/stubs/notification"
require "mudguard/domain/dependencies"
require "mudguard/domain/texts"

module Mudguard
  module Domain
    RSpec.describe Dependencies do
      subject(:analyser) { Dependencies.new(policies: policies, notification: notification) }
      subject(:notification) { Mudguard::Stubs::Notification.new }
      describe "#check" do
        subject(:result_and_messages) do
          result = analyser.check(dependencies)
          { result: result, messages: notification.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }
        context "when no policies" do
          let(:policies) { [] }
          context "and no dependencies" do
            let(:dependencies) { [] }
            it { expect(result).to eq(0) }
            it { expect(messages).to be_empty }
          end

          context "and one dependency" do
            let(:dependencies) do
              [Dependency.new(location: "class.rb:3", dependency: "::A->::B::C")]
            end
            it { expect(result).to eq(1) }
            it "generates message" do
              error = dependency_not_allowed("::A->::B::C")
              expect(messages).to match_array(["class.rb:3 #{error}"])
            end
          end
        end

        context "when one policy" do
          let(:policies) { ["::A->::B"] }
          context "and dependencies are ok" do
            let(:dependencies) { [dependency1, dependency2] }
            let(:dependency1) { Dependency.new(dependency: "::A->::B::C") }
            let(:dependency2) { Dependency.new(dependency: "::A->::B::D") }
            it { expect(result).to eq(0) }
            it { expect(messages).to be_empty }
          end

          context "and one dependency is nok" do
            let(:dependencies) { [dependency1, dependency2] }
            let(:dependency1) { Dependency.new(location: "test.rb:14", dependency: "::A->::B::C") }
            let(:dependency2) { Dependency.new(location: "test.rb:19", dependency: "::A->::C::D") }
            it { expect(result).to eq(1) }
            it { expect(messages).to eq(["test.rb:19 #{dependency_not_allowed('::A->::C::D')}"]) }
          end

          context "and all dependencies are nok" do
            let(:code) { "module A;dep=C::X;dep=D::Y;end" }
            let(:dependencies) { [dependency1, dependency2] }
            let(:dependency1) { Dependency.new(location: "foo.rb:4", dependency: "::A->::C::X") }
            let(:dependency2) { Dependency.new(location: "foo.rb:8", dependency: "::A->::D::Y") }
            it { expect(result).to eq(2) }
            it "generates messages" do
              problem1 = "foo.rb:4 #{dependency_not_allowed('::A->::C::X')}"
              problem2 = "foo.rb:8 #{dependency_not_allowed('::A->::D::Y')}"
              expect(messages).to match_array([problem1, problem2])
            end
          end
        end

        context "when two policies" do
          let(:policies) { %w[::A->::B ::D->::E] }
          context "and two dependencies are nok" do
            let(:dependencies) { [dependency1, dependency2] }
            let(:dependency1) { Dependency.new(location: "test.rb:5", dependency: "::A->::D::C") }
            let(:dependency2) { Dependency.new(location: "test.rb:5", dependency: "::A->::E::C") }
            it { expect(result).to eq(2) }
            it "generates messages" do
              problem1 = "test.rb:5 #{dependency_not_allowed('::A->::D::C')}"
              problem2 = "test.rb:5 #{dependency_not_allowed('::A->::E::C')}"
              expect(messages).to match_array([problem1, problem2])
            end
          end
        end

        context "when policy has comment" do
          let(:policies) { ["::A->::D # a comment"] }
          context "and dependency is ok" do
            let(:dependencies) { [Dependency.new(dependency: "::A->::D::C")] }
            it { expect(result).to eq(0) }
          end
          context "and dependency is nok" do
            let(:dependencies) { [Dependency.new(dependency: "::A->::B::C")] }
            it { expect(result).to eq(1) }
          end
        end
      end

      describe "#print_allowed_dependencies" do
        subject(:result_and_messages) do
          result = analyser.print_allowed(dependencies)
          { result: result, messages: notification.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }
        let(:policies) { %w[::A->::B::D ::A->::X::Y] }
        let(:dependencies) { [dependency1, dependency2] }
        let(:dependency1) { Dependency.new(location: "file1.rb:45", dependency: "::A->::B::C") }
        let(:dependency2) { Dependency.new(location: "file1.rb:25", dependency: "::A->::B::D") }
        it { expect(result).to eq(1) }
        it { expect(messages).to match_array(["file1.rb:25 #{dependency_allowed('::A->::B::D')}"]) }
      end
    end
  end
end
