# frozen_string_literal: true

module Mudguard
  module Domain
    # Processes the interesting parts of the Ast and forwards selected nodes to the visitors
    class SourceProcessor
      def initialize(location:)
        @location = location
      end

      def process(node, visitor)
        process_node(node, visitor, "")
      end

      private

      def process_node(node, visitor, module_name) # rubocop:disable Metrics/MethodLength
        case node
        when type?(:module)
          process_module(node, visitor, module_name)
        when type?(:class)
          process_module(node, visitor, module_name)
        when type?(:const)
          process_const(node, visitor, module_name)
        when type?(:casgn)
          process_const_assignment(node, visitor, module_name)
        else
          ignore_and_continue(node, visitor, module_name)
        end
      end

      def process_const_assignment(node, visitor, module_name)
        is_explicit, const_name = find_const_name(node.children)
        visitor.visit_const_declaration(describe_location(node), const_name,
                                        is_explicit ? "" : module_name)
      end

      def process_const(node, visitor, module_name)
        is_explicit, const_name = find_const_name(node.children)
        visitor.visit_dependency(describe_location(node), const_name,
                                 is_explicit ? "" : module_name)
      end

      def describe_location(node)
        "#{@location}:#{node.location.line}"
      end

      def ignore_and_continue(node, visitor, module_name)
        return unless node.respond_to?(:children)

        node.children.flat_map { |c| process_node(c, visitor, module_name) }
      end

      def process_module(node, visitor, module_name)
        is_explicit, const_name = find_const_name(node.children[0].children)
        visitor.visit_const_declaration(describe_location(node), const_name, module_name)

        module_name = "#{is_explicit ? '' : module_name}#{const_name}"
        node.children.drop(1).reject(&:nil?).each do |child_node|
          process_node(child_node, visitor, module_name)
        end
      end

      def find_const_name(children)
        return [false, nil] if children.nil? || children.empty?

        first_child = children[0]
        is_explicit = first_child.respond_to?(:type) && first_child.type == :cbase
        first_child_children = first_child.respond_to?(:children) ? first_child.children : nil
        _, module_name = find_const_name(first_child_children)
        const_name = children[1].to_s
        [is_explicit, "#{module_name}::#{const_name}"]
      end

      def type?(type)
        ->(n) { n.respond_to?(:type) && n.type == type }
      end
    end
  end
end
