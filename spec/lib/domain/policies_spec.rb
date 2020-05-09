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

        context "when two sources" do
          let(:sources) { [source1, source2] }
          let(:file1) { "./dir/source1.rb" }
          let(:source1) { Source.new(location: file1, code: code1) }
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
          let(:file2) { "./dir/source2.rb" }
          let(:source2) { Source.new(location: file2, code: code2) }
          let(:code2) { "module B;dep=D::C;end" }
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
          let(:policies) { ["::A->::A::B::D"] }

          it { expect(result).to be_falsey }
          it "generates messages" do
            problem1 = "#{file1}:2 #{dependency_not_allowed('::A->::B::C')}"
            problem2 = "#{file2}:2 #{dependency_not_allowed('::B->::B::D::C')}"
            expect(messages).to match_array([problem1, problem2, summary(2, 2)])
          end
        end
      end
    end
  end
end
