# frozen_string_literal: true

require "optparse"
require "mudguard/application/application"
require_relative "notification_adapter"

module Mudguard
  module Infrastructure
    module Cli
      # Parses the cli arguments
      class Controller
        def initialize(view:) # rubocop:disable Metrics/MethodLength
          @cmd = :analyse
          @view = view
          @display_opts = {
            view: view,
            compressed: false
          }
          @parser = ::OptionParser.new do |opts|
            opts.banner = "Usage: mudguard [options] [directory]"
            opts.on("-h", "--help", "Prints this help") do
              @cmd = :help
            end
            opts.on("-p", "--print", "Prints all allowed dependencies") do
              @cmd = :print_allowed
            end
            opts.on("-c", "--compressed", "Omits printing the same dependency more than once") do
              @display_opts[:compressed] = true
            end
          end
        end

        def parse!(argv) # rubocop:disable Metrics/MethodLength
          directories = @parser.parse!(argv)

          case @cmd
          when :print_allowed
            print_allowed_dependencies(directories)
          when :help
            help
          when :analyse
            check_dependencies(directories)
          else
            raise StandardError, "unknown command #{@cmd}"
          end
        end

        private

        def help
          @view.print(@parser.to_s)
          true
        end

        def check_dependencies(directories)
          yield_directories(directories) do |directory, notification|
            Mudguard::Application.check(directory, notification)
          end
        end

        def print_allowed_dependencies(directories)
          yield_directories(directories) do |directory, notification|
            Mudguard::Application.print_allowed_dependencies(directory, notification)
            true
          end
        end

        def yield_directories(directories)
          notification = NotificationAdapter.new(**@display_opts)
          directories = [Dir.pwd] if directories.empty?
          directories.all? do |directory|
            yield directory, notification
          end
        end
      end
    end
  end
end
