# frozen_string_literal: true

require "rake"
require "rake/tasklib"
require_relative "../../application/application"
require_relative "../../infrastructure/cli/notification_adapter"
require_relative "../../infrastructure/cli/view"

module Mudguard
  module Infrastructure
    module Rake
      # Provides Mudguard Rake Tasks
      class Task < ::Rake::TaskLib
        def initialize(project_dir: Dir.pwd)
          super()

          @project_dir = project_dir

          desc "Run Mudguard"
          task(:mudguard) do
            view = Mudguard::Infrastructure::Cli::View.new
            notification = Mudguard::Infrastructure::Cli::NotificationAdapter.new(view: view)
            ok = Application.check(@project_dir, notification)
            abort unless ok
          end
        end
      end
    end
  end
end
