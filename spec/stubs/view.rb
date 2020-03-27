# frozen_string_literal: true

module Mudguard
  module Stubs
    class View
      attr_reader :messages

      def initialize
        @messages = []
      end

      def print(message)
        @messages << message
      end
    end
  end
end
