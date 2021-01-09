# frozen_string_literal: true

require "spec_helper"
require "mudguard/domain/error"
require "mudguard/infrastructure/persistence/ruby_files"
require "mudguard/domain/source"
require_relative "../../../test_projects/test_projects"

module Mudguard
  module Infrastructure
    module Persistence
      RSpec.describe RubyFiles do
        describe ".select" do
          context "when dir not exists" do
            it "raises an error" do
              expect { RubyFiles.select("/somewhere/not_existing") }
                .to raise_error(Mudguard::Domain::Error)
            end
          end

          context "when empty project" do
            subject(:ruby_files) { RubyFiles.select(TestProjects::PATH_TO_EMPTY_DIR) }
            it { expect(ruby_files.any?).to be_falsey }
          end

          context "when hierarchical project" do
            let(:project_path) { TestProjects::PATH_TO_HIERARCHICAL_PROJECT }
            let(:sources_in_path) do
              files_in_path.map do |f|
                path = File.join(project_path, f)
                Mudguard::Domain::Source.new(location: f, code_loader: -> { File.read(path) })
              end
            end

            context "without pattern" do
              subject(:ruby_files) { RubyFiles.select(project_path) }
              let(:files_in_path) { %w[./root.rb ./a/a.rb ./a/b/b.rb] }

              it { expect(ruby_files).to match_array(sources_in_path) }
            end

            context "with pattern" do
              subject(:ruby_files) do
                RubyFiles.select(project_path, patterns: %w[./**/*.mod ./a/a.txt])
              end
              let(:files_in_path) { %w[./a/b/b.mod ./a/a.txt] }

              it { expect(ruby_files).to match_array(sources_in_path) }
            end
          end

          context "when project contains only directory with extension .rb" do
            subject(:ruby_files) { RubyFiles.select(project_path) }
            let(:project_path) do
              File.expand_path("project_containing_dir_with_rb_extension", File.dirname(__FILE__))
            end

            it { expect(ruby_files).to be_empty }
          end
        end
      end
    end
  end
end
