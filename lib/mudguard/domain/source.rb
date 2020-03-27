# frozen_string_literal: true

require "parser/current"
require "mudguard/domain/dependency"

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

      def find_mod_dependencies
        begin
          root = Parser::CurrentRuby.parse(@code)
        rescue Parser::SyntaxError
          return []
        end
        return [] if root.nil?

        process(root)
      end

      private

      def process(node, module_name = "")
        case node
        when type?(:module)
          process_module(node.children)
        when type?(:class)
          process_class(node.children, module_name)
        when type?(:const)
          [create_dependency(module_name, node)]
        else
          ignore_and_continue(node, module_name)
        end
      end

      def create_dependency(module_name, node)
        dependency = "#{module_name}->#{find_const_name(node.children)}"
        location = "#{@location}:#{node.location.line}"
        Dependency.new(location: location, dependency: dependency)
      end

      def ignore_and_continue(node, module_name)
        case node
        when children?
          node.children.flat_map { |c| process(c, module_name) }
        else
          []
        end
      end

      def process_module(children)
        module_name = find_const_name(children[0].children)
        process(children[1], module_name)
      end

      def process_class(children, module_name)
        process(children[1], module_name)
      end

      def find_const_name(children)
        return nil if children.nil?

        module_name = find_const_name(children[0]&.children)
        const_name = children[1].to_s
        if module_name.nil?
          const_name
        else
          "#{module_name}::#{const_name}"
        end
      end

      def children?
        ->(n) { n.respond_to?(:children) }
      end

      def type?(type)
        ->(n) { n.respond_to?(:type) && n.type == type }
      end
    end
  end
end
