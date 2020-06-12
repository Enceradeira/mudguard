# frozen_string_literal: true

require_relative "../../../stubs/view"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.shared_context "Controller" do
        subject(:parser) { Controller.new(view: view) }
        subject(:result_and_messages) do
          result = parser.parse!(argv)
          { result: result, messages: view.messages }
        end
        subject(:result) { result_and_messages[:result] }
        subject(:messages) { result_and_messages[:messages] }
        let(:view) { Mudguard::Stubs::View.new }
      end
    end
  end
end
