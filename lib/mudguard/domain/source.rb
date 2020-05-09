# frozen_string_literal: true

require "parser/current"
require_relative "dependency"
require_relative "dependency_visitor"
require_relative "const_visitor"
require_relative "error"

module Mudguard
  module Domain
    # Represents a Ruby source file
    class Source
      def initialize(location: nil, code:)
        @code = code
        @location = location
      end

      def ==(other)
        @code == other.instance_eval { @code } && @location == other.instance_eval { @location }
      end

      def inspect
        @location
      end

      def find_mod_dependencies(consts)
        visitor = DependencyVisitor.new(consts: consts)
        visit_ast(visitor)
        visitor.dependencies
      end

      def find_consts
        visitor = ConstVisitor.new
        visit_ast(visitor)
        visitor.consts
      end

      private

      SYNTAX_ERROR = "error"

      def ast
        @ast ||= create_ast
      end

      def create_ast
        begin
          root = Parser::CurrentRuby.parse(@code)
        rescue Parser::SyntaxError
          return SYNTAX_ERROR
        end
        root.nil? ? SYNTAX_ERROR : root
      end

      def visit_ast(visitor)
        return if ast == SYNTAX_ERROR

        process(ast, visitor, "")
      end

      def process(node, visitor, module_name)
        case node
        when type?(:module)
          process_module(node, visitor, module_name)
        when type?(:class)
          process_module(node, visitor, module_name)
        when type?(:const)
          process_const(node, visitor, module_name)
        else
          ignore_and_continue(node, visitor, module_name)
        end
      end

      def process_const(node, visitor, module_name)
        const_name = find_const_name(node.children)
        visitor.visit_dependency(describe_location(node), const_name, module_name)
      end

      def describe_location(node)
        "#{@location}:#{node.location.line}"
      end

      def ignore_and_continue(node, visitor, module_name)
        return unless node.respond_to?(:children)

        node.children.flat_map { |c| process(c, visitor, module_name) }
      end

      def process_module(node, visitor, module_name)
        const_name = find_const_name(node.children[0].children)
        const_name = module_name.empty? ? "::#{const_name}" : const_name
        visitor.visit_const_declaration(describe_location(node), const_name, module_name)

        module_name = module_name.empty? ? const_name : "#{module_name}::#{const_name}"
        node.children.drop(1).reject(&:nil?).each do |child_node|
          process(child_node, visitor, module_name)
        end
      end

      def find_const_name(children)
        return nil if children.nil?

        first_child = children[0]
        first_child_children = first_child.respond_to?(:children) ? first_child.children : nil
        module_name = find_const_name(first_child_children)
        const_name = children[1].to_s
        if module_name.nil?
          const_name
        else
          "#{module_name}::#{const_name}"
        end
      end

      def type?(type)
        ->(n) { n.respond_to?(:type) && n.type == type }
      end
    end
  end
end
