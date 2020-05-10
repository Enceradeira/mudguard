# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Texts do
      subject(:texts) { Class.new.extend(Texts) }
      describe ".summary" do
        it { expect(texts.summary(0, 0)).to eq("0 files inspected, no bad dependency detected") }
        it { expect(texts.summary(1, 1)).to eq("1 file inspected, 1 bad dependency detected") }
        it { expect(texts.summary(2, 5)).to eq("2 files inspected, 5 bad dependencies detected") }
      end
      describe ".dependency_summary" do
        context "when 0 files inspected" do
          it "is correct" do
            expect(texts.dependency_summary(0, 0))
              .to eq("0 files inspected, no good dependency detected")
          end
        end
        context "when 1 file inspected" do
          it "is correct" do
            expect(texts.dependency_summary(1, 1))
              .to eq("1 file inspected, 1 good dependency detected")
          end
        end
        context "when 2 files inspected" do
          it "is correct" do
            expect(texts.dependency_summary(2, 5))
              .to eq("2 files inspected, 5 good dependencies detected")
          end
        end
      end
      describe ".dependency_not_allowed" do
        it { expect(texts.dependency_not_allowed("A->B")).to eq("A->B not allowed") }
      end
      describe ".dependency_allowed" do
        it { expect(texts.dependency_allowed("A->B")).to eq("A->B") }
      end
    end
  end
end
