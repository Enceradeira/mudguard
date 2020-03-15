# frozen_string_literal: true

require "rspec/core/rake_task"
require "mudguard/version"

namespace :gem do
  desc "Publishes the gem on rubygems.org"
  task publish: "gem:build" do
    exec("gem push mudguard-#{Mudguard::VERSION}.gem")
  end
  desc "Builds the gem"
  task :build do
    exec("gem build mudguard.gemspec")
  end
end
