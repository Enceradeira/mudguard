# frozen_string_literal: true

require "spec_helper"
require "mudguard/domain/error"
require "mudguard/persistence/ruby_files"
require_relative "../../test_projects/test_projects"

module Mudguard
  module Persistence
    RSpec.describe RubyFiles do
      describe ".all" do
        subject(:ruby_files) { RubyFiles.all(prj_path) }

        context "when dir not exists" do
          it "raises an error" do
            expect { RubyFiles.all("/somewhere/not_existing") }
              .to raise_error(Mudguard::Domain::Error)
          end
        end

        context "when empty project" do
          let(:prj_path) { TestProjects::PATH_TO_EMPTY_DIR }

          it { expect(ruby_files.any?).to be_falsey }
        end

        context "when hierarchical project" do
          let(:prj_path) { TestProjects::PATH_TO_HIERARCHICAL_PROJECT }

          it "returns all ruby-files" do
            all_rb_files = %W[#{prj_path}/root.rb #{prj_path}/a/a.rb #{prj_path}/a/b/b.rb]
            expect(ruby_files).to match_array(all_rb_files)
          end
        end
      end
    end
  end
end
