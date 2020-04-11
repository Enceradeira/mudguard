# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Texts do
      subject(:texts) { Class.new.extend(Texts) }
      describe ".summary" do
        it { expect(texts.summary(0, 0)).to eq("0 files inspected, 0 problems detected") }
        it { expect(texts.summary(1, 1)).to eq("1 file inspected, 1 problem detected") }
        it { expect(texts.summary(2, 5)).to eq("2 files inspected, 5 problems detected") }
      end
      describe ".dependency_not_allowed" do
        it { expect(texts.dependency_not_allowed("A->B")).to eq("A->B not allowed") }
      end
    end
  end
end
