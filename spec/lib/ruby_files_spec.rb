# frozen_string_literal: true

require "spec_helper"
require "mudguard/error"
require "mudguard/ruby_files"
require_relative "../test_projects/test_projects"

module Mudguard
  RSpec.describe RubyFiles do
    describe ".all" do
      subject(:ruby_files) { RubyFiles.all(project_path) }

      context "when dir not exists" do
        it { expect { RubyFiles.all("/somewhere/not_existing") }.to raise_error(Error) }
      end

      context "when empty project" do
        let(:project_path) { TestProjects::PATH_TO_EMPTY_DIR }

        it { expect(ruby_files.any?).to be_falsey }
      end

      context "when hierarchical project" do
        let(:project_path) { TestProjects::PATH_TO_HIERARCHICAL_PROJECT }

        it "returns all ruby-files" do
          all_rb_files = %W[#{project_path}/root.rb #{project_path}/a/a.rb #{project_path}/a/b/b.rb]
          expect(ruby_files).to match_array(all_rb_files)
        end
      end
    end
  end
end
