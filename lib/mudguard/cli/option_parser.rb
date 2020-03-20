# frozen_string_literal: true

require "optparse"
require "mudguard"

module Mudguard
  module Cli
    # Parses the cli arguments
    class OptionParser
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

        directories = [Dir.pwd] if directories.empty?
        directories.any? && directories.all?(&Mudguard.method(:check))
      end
    end
  end
end
