# frozen_string_literal: true

require "spec_helper"

module Mudguard
  RSpec.describe RubyAnalyser do
    describe ".find_mod_dependencies" do
      subject(:dependencies) { RubyAnalyser.find_mod_dependencies(source) }
      context "when empty" do
        let(:source) { "" }
        it { is_expected.to be_empty }
      end
      context "when ruby invalid" do
        let(:source) { "module" }
        it { is_expected.to be_empty }
      end

      context "when ruby has no dependencies" do
        let(:source) { "module A;end" }
        it { is_expected.to be_empty }
      end

      context "when ruby has dependencies" do
        let(:source) { "module A;b=B::C;end" }
        it { is_expected.to match_array(["A->B::C"]) }
      end

      context "when ruby contains declaration without module" do
        let(:source) { "class A;end" }
        it { is_expected.to be_empty }
      end

      context "when ruby contains declaration in module" do
        let(:source) { "module A;class B;end;end" }
        it { is_expected.to be_empty }
      end
    end
  end
end
