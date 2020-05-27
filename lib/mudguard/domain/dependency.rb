# frozen_string_literal: true

module Mudguard
  module Domain
    # A Dependency between Modules
    class Dependency
      attr_reader :location, :dependency

      def initialize(location: nil, dependency:)
        @location = location
        @dependency = dependency
      end

      def inspect
        "{#{@location}, #{@dependency}}"
      end

      def match(policy)
        @dependency.match(policy)
      end

      def ==(other)
        @location == other.instance_eval { @location } &&
          @dependency == other.instance_eval { @dependency }
      end
    end
  end
end
