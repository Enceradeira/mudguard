# frozen_string_literal: true

require "spec_helper"

require "mudguard/domain/source"

module Mudguard
  module Domain
    RSpec.describe Source do
      subject(:source) { Source.new(location: "test.rb", code: code) }
      describe ".find_mod_dependencies" do
        subject(:dependencies) { source.find_mod_dependencies }
        context "when empty" do
          let(:code) { "" }
          it { is_expected.to be_empty }
        end
        context "when ruby invalid" do
          let(:code) { "module" }
          it { is_expected.to be_empty }
        end

        context "when ruby has no dependencies" do
          let(:code) { "module A;end" }
          it { is_expected.to be_empty }
        end

        context "when ruby has dependencies" do
          let(:code) { "module A;b=B::C;end" }
          it { is_expected.to match_array(["A->B::C"]) }
        end

        context "when ruby contains declaration without module" do
          let(:code) { "class A;end" }
          it { is_expected.to be_empty }
        end

        context "when ruby contains declaration in module" do
          let(:code) { "module A;class B;end;end" }
          it { is_expected.to be_empty }
        end
      end
    end
  end
end
