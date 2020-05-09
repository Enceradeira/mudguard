# frozen_string_literal: true

module Mudguard
  module Domain
    # Transforms AST-Nodes into Dependencies
    class DependencyVisitor
      def initialize(consts:)
        @consts = consts
        @dependencies = []
      end

      attr_reader :dependencies

      def visit_dependency(location, const_name, module_name)
        qualified_const_name = @consts.resolve(module_name, const_name)
        return [] unless qualified_const_name&.include?("::")

        dependency = if module_name.empty?
                       qualified_const_name
                     else
                       "#{module_name}->#{qualified_const_name}"
                     end

        @dependencies << Dependency.new(location: location, dependency: dependency)
      end

      def visit_const_declaration(_, __, ___); end
    end
  end
end
