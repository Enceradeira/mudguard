# frozen_string_literal: true

module Mudguard
  module Stubs
    class Notification
      attr_reader :messages

      def initialize
        @messages = []
      end

      def add(location, message)
        @messages << if location.nil?
                       message
                     else
                       "#{location} #{message}"
                     end
      end
    end
  end
end
