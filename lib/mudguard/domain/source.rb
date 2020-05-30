# frozen_string_literal: true

require "parser/current"
require_relative "dependency"
require_relative "dependency_visitor"
require_relative "const_visitor"
require_relative "error"
require_relative "source_processor"

module Mudguard
  module Domain
    # Represents a Ruby source file
    class Source
      def initialize(location:, code_loader: -> { "" })
        @code_loader = code_loader
        @location = location
      end

      def ==(other)
        @location == other.instance_eval { @location }
      end

      def hash
        @location.hash
      end

      def eql?(other)
        @location.eql?(other.instance_eval { @location })
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

      def location?(glob)
        @location == glob
      end

      private

      SYNTAX_ERROR = "error"

      def ast
        @ast ||= create_ast
      end

      def create_ast
        begin
          root = Parser::CurrentRuby.parse(code)
        rescue Parser::SyntaxError
          return SYNTAX_ERROR
        end
        root.nil? ? SYNTAX_ERROR : root
      end

      def code
        @code ||= @code_loader.call
      end

      def visit_ast(visitor)
        return if ast == SYNTAX_ERROR

        SourceProcessor.new(location: @location).process(ast, visitor, "")
      end
    end
  end
end
