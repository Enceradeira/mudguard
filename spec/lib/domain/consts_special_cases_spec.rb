# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Consts do
      subject(:consts) { Consts.new(sources: sources) }
      describe "#resolve" do
        context "when module declared inline" do
          let(:sources) do
            [Source.new(location: "test1.rb", code_loader: -> { code1 }),
             Source.new(location: "test2.rb", code_loader: -> { code2 })]
          end
          let(:code1) { "class A::B::D;end" }
          let(:code2) { "module A; allowed_dependency=B::D; end" }

          it { expect(consts.resolve("::A", "::B::D")).to eq("::A::B::D") }
        end
      end
    end
  end
end
