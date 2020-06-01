# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Source do
      subject(:source) { Source.new(location: "test.rb", code_loader: -> { code }) }
      describe "#find_consts" do
        subject(:consts) { source.find_consts }
        let(:code) { File.read(File.join(__dir__, "source_examples", file)) }
        context "when example 1" do
          let(:file) { "example1.rb" }
          it { is_expected.to include("::A") }
        end
        context "when example 2" do
          let(:file) { "example2.rb" }
          it { is_expected.to include("::A::B") }
        end
        context "when example 3 " do
          let(:file) { "example3.rb" }
          it { is_expected.to include("::Dependency") }
        end
      end
    end
  end
end
