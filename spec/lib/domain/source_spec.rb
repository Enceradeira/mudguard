# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Source do
      subject(:source) { Source.new(location: "test.rb", code: code) }
      describe "#find_consts" do
        subject(:consts) { source.find_consts }
        context "when code valid" do
          let(:code) do
            <<CODE
  class A
  end
  module M
    class A
    end
    module N
      class B
        class C
        end
      end
    end
  end
CODE
          end
          it { is_expected.to include("::A") }
          it { is_expected.to include("::M") }
          it { is_expected.to include("::M::A") }
          it { is_expected.to include("::M::N") }
          it { is_expected.to include("::M::N::B") }
          it { is_expected.to include("::M::N::B::C") }
          it { expect(consts.length).to eq(6) }
        end

        context "when code invalid" do
          let(:code) { "class; B" }
          it { is_expected.to be_empty }
        end
      end

      describe "#find_mod_dependencies" do
        subject(:dependencies) { source.find_mod_dependencies(consts) }
        let(:consts) { Consts.new(sources: [source]) }
        context "when empty" do
          let(:code) { "" }
          it { is_expected.to be_empty }
        end

        context "when code invalid" do
          let(:code) { "module" }
          it { is_expected.to be_empty }
        end

        context "when code has no dependencies" do
          let(:code) { "module A;end" }
          it { is_expected.to be_empty }
        end

        context "when code has dependencies" do
          context "and module is not nested" do
            let(:code) { "module A;b=B::C;end" }
            it { expect(dependencies).to include_dependency("test.rb:1", "::A->::B::C") }
          end
          context "and module is nested using compact style" do
            let(:code) { "module A::B;b=B::C;end" }
            it { expect(dependencies).to include_dependency("test.rb:1", "::A::B->::B::C") }
          end
          context "and module is nested" do
            let(:code) do
              %(
                module A
                  module B
                    c = B::C;
                  end
                end
              )
            end
            it { expect(dependencies).to include_dependency("test.rb:4", "::A::B->::B::C") }
          end
        end

        context "when code has dependency to const in same module" do
          let(:code) { "module A;b=B;class B;end;end" }
          it { expect(dependencies).to include_dependency("test.rb:1", "::A->::A::B") }
        end

        context "when code contains declaration without module" do
          let(:code) { "class A;end" }
          it { is_expected.to be_empty }
        end

        context "when code depends on other unknown module" do
          let(:code) { "class A < B::C;end" }
          it { expect(dependencies).to include_dependency("test.rb:1", "::A->::B::C") }
        end

        context "when code contains declaration in module" do
          let(:code) { "module A;class B;end;end" }
          it { is_expected.to be_empty }
        end

        context "when code dependency is outside module declaration" do
          let(:code) { "dependency = A;" }
          it { expect(dependencies).to include_dependency("test.rb:1", "->::A") }
        end
      end
    end
  end
end
