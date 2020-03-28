# frozen_string_literal: true

require "rspec/expectations"
require "mudguard/domain/dependency"

RSpec::Matchers.define :include_dependency do |expected_location, expected_dependency|
  dependency = Mudguard::Domain::Dependency.new(location: expected_location,
                                                dependency: expected_dependency)
  match do |actual|
    actual.include?(dependency)
  end

  failure_message do |actual|
    "expected #{actual.inspect} to include #{dependency.inspect}"
  end
end
