# frozen_string_literal: true

module Mudguard
  module Stubs
    class Notification

      attr_reader :messages

      def initialize
        @messages = []
      end

      def add(message)
        @messages << message
      end
    end
  end
end