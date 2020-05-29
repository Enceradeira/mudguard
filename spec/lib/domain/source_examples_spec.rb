# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Source do
      subject(:source) { Source.new(location: "test.rb", code_loader: -> { code }) }
      describe "#find_consts" do
        subject(:consts) { source.find_consts }
        context "example 1" do
          let(:code) { File.read(File.join(__dir__, "source_examples", "example1.rb")) }
          it { is_expected.to include("::A") }
        end
      end
    end
  end
end
