# frozen_string_literal: true

require "spec_helper"
require "mudguard/infrastructure/cli/notification_adapter"
require_relative "../../../stubs/view"

module Mudguard
  module Infrastructure
    module Cli
      RSpec.describe NotificationAdapter do
        subject(:adapter) { NotificationAdapter.new(view: view, compressed: compressed) }
        let(:view) { Stubs::View.new }
        describe "#add" do
          before do
            adapter.add("test.rb:1", "Error 1")
            adapter.add("test.rb:5", "Error 1")
            adapter.add("test.rb:5", "Error 2")
            adapter.add(nil, "Several errors occurred")
          end
          context "when not compressed output" do
            let(:compressed) { false }
            it "prints each location and text" do
              expect(view.messages).to match_array(["test.rb:1 Error 1",
                                                    "test.rb:5 Error 1",
                                                    "test.rb:5 Error 2",
                                                    "Several errors occurred"])
            end
          end

          context "when compressed output" do
            let(:compressed) { true }
            it "prints each text only once" do
              expect(view.messages).to match_array(["Error 1",
                                                    "Error 2",
                                                    "Several errors occurred"])
            end
          end
        end
      end
    end
  end
end
