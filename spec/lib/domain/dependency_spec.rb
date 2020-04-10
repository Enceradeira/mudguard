# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe "#match" do
      subject(:dependency) { Dependency.new(dependency: "A->B::C") }
      it { expect(dependency.match(/A->B::C/)).to be_truthy }
      it { expect(dependency.match(/A->B::C # comment/x)).to be_truthy }
      it { expect(dependency.match(/A->D::C/)).to be_falsey }
    end
  end
end
