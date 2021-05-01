# frozen_string_literal: true

module Mudguard
  module Domain
    # A Dependency between Modules
    class Dependency
      attr_reader :location, :dependency

      def initialize(dependency:, location: nil)
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
