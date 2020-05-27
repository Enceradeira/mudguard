# frozen_string_literal: true

module Mudguard
  module Infrastructure
    module Cli
      # Forwards Notification to the view for printing
      class NotificationAdapter
        def initialize(view:, compressed: false)
          @view = view
          @compressed = compressed
          @printed_texts = Set.new
        end

        def add(location, text)
          text = if location.nil? || @compressed
                   text
                 else
                   "#{location} #{text}"
                 end
          @view.print(text) unless @printed_texts.include?(text)
          @printed_texts << text
        end
      end
    end
  end
end
