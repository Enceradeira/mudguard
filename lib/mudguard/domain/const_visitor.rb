# frozen_string_literal: true

module Mudguard
  module Domain
    # Transforms AST-Nodes into Strings denoting consts
    class ConstVisitor
      def initialize
        @consts = []
      end

      attr_reader :consts

      def visit_dependency(_, __, ___); end # rubocop:disable Naming/MethodParameterName

      def visit_const_declaration(_location, const_name, module_name)
        @consts << if module_name.empty?
                     const_name
                   else
                     "#{module_name}::#{const_name}"
                   end
      end
    end
  end
end
