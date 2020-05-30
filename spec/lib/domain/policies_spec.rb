# frozen_string_literal: true

require "spec_helper"
require_relative "../../../spec/stubs/notification"

module Mudguard
  module Domain
    RSpec.describe Policies do
      subject(:notification) { Mudguard::Stubs::Notification.new }

      describe "#check" do
        subject(:result_and_messages) do
          result = Policies.new(source_policies: source_policies).check(notification)
          { result: result, messages: notification.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }

        context "when two sources" do
          let(:source_policies) { [source_policies1, source_policies2] }
          let(:file1) { "./dir/source1.rb" }
          let(:source1) { Source.new(location: file1, code_loader: -> { code1 }) }
          let(:code1) do
            <<CODE
  module A
    bad_dependency = B::C

    module B
      class D
      end
    end
  end
  module B
    module D
      class C
      end
    end
  end
CODE
          end
          let(:policies1) { ["::A->::A::B::D"] }
          let(:source_policies1) { SourcePolicies.new(source: source1, policies: policies1) }

          let(:file2) { "./dir/source2.rb" }
          let(:source2) { Source.new(location: file2, code_loader: -> { code2 }) }
          let(:code2) do
            <<CODE
  module B
    bad_dependency=D::C
  end

  module A
   allowed_dependency=B::D
  end
CODE
          end
          let(:policies2) { ["::A->::A::B::D"] }
          let(:source_policies2) { SourcePolicies.new(source: source2, policies: policies2) }

          it { expect(result).to be_falsey }
          it "generates messages" do
            problem1 = "#{file1}:2 #{dependency_not_allowed('::A->::B::C')}"
            problem2 = "#{file2}:2 #{dependency_not_allowed('::B->::B::D::C')}"
            expect(messages).to match_array([problem1, problem2, summary(2, 2)])
          end
        end
      end

      describe "#print_allowed_dependencies" do
        subject(:messages) do
          Policies.new(source_policies: source_policies).print_allowed_dependencies(notification)
          notification.messages
        end
        let(:source_policies) { [source_policies1, source_policies2] }
        let(:policies) { %w[::A->::B::C ::B->::B::D] }
        let(:file1) { "./dir/source1.rb" }
        let(:source1) { Source.new(location: file1, code_loader: -> { code1 }) }
        let(:code1) do
          <<CODE
  module B
    bad_dependency=D::C
    allowed_dependency=B::D::C
  end
CODE
        end
        let(:source_policies1) { SourcePolicies.new(source: source1, policies: policies) }

        let(:file2) { "./dir/source2.rb" }
        let(:source2) { Source.new(location: file2, code_loader: -> { code2 }) }
        let(:code2) do
          <<CODE
  module A
   allowed_dependency=B::C
  end
CODE
        end
        let(:source_policies2) { SourcePolicies.new(source: source2, policies: policies) }
        let(:source_policies) { [source_policies1, source_policies2] }

        it "generates messages" do
          message1 = "#{file1}:3 #{dependency_allowed('::B->::B::D::C')}"
          message2 = "#{file2}:2 #{dependency_allowed('::A->::B::C')}"
          expect(messages).to match_array([message1, message2, dependency_summary(2, 2)])
        end
      end
    end
  end
end
