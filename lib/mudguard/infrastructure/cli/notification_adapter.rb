# frozen_string_literal: true

module Mudguard
  module Infrastructure
    module Cli
      # Forwards Notification to the view for printing
      class NotificationAdapter
        def initialize(view:)
          @view = view
        end

        def add(text)
          @view.print(text)
        end
      end
    end
  end
end
