# frozen_string_literal: true

require_relative "error"

module Mudguard
  module Domain
    # Knows all constants of the project
    class Consts
      def initialize(sources:)
        @consts = sources
                  .flat_map(&:find_consts)
                  .each_with_object(Hash.new { |h, k| h[k] = {} }) do |c, a|
          path = split_hierarchy(c)
          const_name = path.last
          module_names = path.take(path.count - 1)
          sub_module = module_names.reduce(a) { |h, m| h[m] }
          sub_module[const_name] = {} unless sub_module.key?(const_name)
        end
      end

      def resolve(module_name, const_name)
        raise Error, "const_name is undefined" if const_name.empty?

        path = split_hierarchy(module_name)
        if module_name.empty?
          # not in a module therefor const can only be defined in the root module (::)
          qualified_path(const_name)
        else
          # analyse module hierarchy to find fully qualified const name
          # resolve_in_modules(const_name, path)
          const_path = const_name.split(SEPARATOR).drop(1)
          find_const_deeper("", path, @consts, const_path) || qualified_path(const_name)
        end
      end

      private

      SEPARATOR = "::"

      def find_const_deeper(current_module, remaining_modules, consts, const_path)
        return if consts.nil?

        if remaining_modules.any?
          # Move deeper toward target module
          next_module = remaining_modules.first
          next_remaining = remaining_modules.drop(1)
          next_consts = consts[next_module]
          found_const = find_const_deeper(next_module, next_remaining, next_consts, const_path)
          return join_path(current_module, found_const) if found_const
        end

        find_const(current_module, consts, const_path)
      end

      def find_const(current_module, consts, const_path)
        const_name = const_path.first
        if const_path.length == 1 && consts.key?(const_name)
          # const defined in current_module
          return join_path(current_module, const_name)
        end

        # backward search (along const_path only)
        next_path = const_path.drop(1)
        found_const = find_const_deeper(const_name, next_path, consts[const_name], next_path)
        found_const ? join_path(current_module, found_const) : nil
      end

      def join_path(module_name, const_name)
        "#{module_name}#{SEPARATOR}#{const_name}"
      end

      def qualified_path(const_name)
        const_name =~ /^#{SEPARATOR}/ ? const_name : "#{SEPARATOR}#{const_name}"
      end

      def split_hierarchy(module_name)
        module_name.split(SEPARATOR).drop(1)
      end
    end
  end
end
