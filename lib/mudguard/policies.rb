# frozen_string_literal: true

require_relative "ruby_analyser"

module Mudguard
  # Contains the policies to be enforced
  class Policies
    def initialize(policies: [])
      @policies = policies.map { |l| l.gsub(/\s/, "") }.map { |p| /^#{p}/ }
    end

    def check(sources)
      sources.all? do |source|
        dependencies = RubyAnalyser.find_mod_dependencies(source)
        dependencies.all? do |d|
          @policies.any? do |p|
            d.match?(p)
          end
        end
      end
    end
  end
end
