# frozen_string_literal: true

require "optparse"
require "mudguard/application/application"
require_relative "notification_adapter"

module Mudguard
  module Infrastructure
    module Cli
      # Parses the cli arguments
      class Controller
        def initialize(view:)
          @view = view
          @done = false
          @parser = ::OptionParser.new do |opts|
            opts.banner = "Usage: mudguard [options] [directory]"
            opts.on("-h", "--help", "Prints this help") do
              view.print(opts.to_s)
              @done = true
            end
          end
        end

        def parse!(argv)
          directories = @parser.parse!(argv)

          return true if @done

          notification = NotificationAdapter.new(view: @view)
          directories = [Dir.pwd] if directories.empty?
          directories.all? { |d| Mudguard::Application.check(d, notification) }
        end
      end
    end
  end
end
