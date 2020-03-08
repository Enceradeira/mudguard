# frozen_string_literal: true

require "rspec/core/rake_task"

namespace :test do
  namespace :rspec do
    desc "Executes all RSpec tests"
    RSpec::Core::RakeTask.new(:all) do |t|
      t.rspec_opts = ""
    end
  end

  desc "Executes all tests and checks"
  task full: %i[test:rspec:all rubocop]
end

desc "Executes all tests and checks"
task test: "test:full"
