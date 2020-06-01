# frozen_string_literal: true

require "spec_helper"

module Mudguard
  module Domain
    RSpec.describe Consts do
      subject(:consts) { Consts.new(sources: sources) }
      describe "#resolve" do
        context "when on source" do
          let(:sources) { [Source.new(location: "test1.rb", code_loader: -> { code })] }
          let(:code) do
            <<CODE
  class C
  end

  module M
    class B
    end
  end

  module A
    module B
      module C
        module G
        end
        module E
        end
      end
      module D
        module G
        end
        module E
        end
      end
    end
    class D
      class G
      end
    end
  end
  module C
    module E
    end
  end
CODE
          end
          it { expect(consts.resolve("", "::C")).to eq("::C") }
          it { expect(consts.resolve("", "::B")).to eq("::B") }
          it { expect(consts.resolve("::M", "::M::B")).to eq("::M::B") }
          it { expect(consts.resolve("::M", "::B")).to eq("::M::B") }
          it { expect(consts.resolve("", "::X::Y")).to eq("::X::Y") }
          it { expect(consts.resolve("::A", "::X::Y")).to eq("::X::Y") }
          it { expect(consts.resolve("::A::B::D", "::X::Y")).to eq("::X::Y") }
          it { expect(consts.resolve("::A::B::C::G", "::B")).to eq("::A::B") }
          it { expect(consts.resolve("::A::B::C", "::B")).to eq("::A::B") }
          it { expect(consts.resolve("::A::B", "::B")).to eq("::A::B") }
          it { expect(consts.resolve("::A", "::B")).to eq("::A::B") }
          it { expect(consts.resolve("::A::B::D::E", "::D::E")).to eq("::A::B::D::E") }
          it { expect(consts.resolve("::A::B::D::E", "::B::D")).to eq("::A::B::D") }
          it { expect(consts.resolve("::A::B::D::E", "::B::C")).to eq("::A::B::C") }
          it { expect(consts.resolve("::A::B::D::E", "::B::C::G")).to eq("::A::B::C::G") }
          it { expect(consts.resolve("::A::B::D", "::B::C::G")).to eq("::A::B::C::G") }
          it { expect(consts.resolve("::A::B", "::B::C::G")).to eq("::A::B::C::G") }
          it { expect(consts.resolve("::A::B", "::C::G")).to eq("::A::B::C::G") }
          it { expect(consts.resolve("::A::B", "::G")).to eq("::G") }
          it { expect(consts.resolve("::A", "::A::B::D::G")).to eq("::A::B::D::G") }
          it { expect(consts.resolve("::A::B::D", "::G")).to eq("::A::B::D::G") }
          it { expect(consts.resolve("::A::B::D::E", "::D::G")).to eq("::A::B::D::G") }
          it { expect(consts.resolve("::A::B::D", "::D::G")).to eq("::A::B::D::G") }
          it { expect(consts.resolve("::A::B", "::D::G")).to eq("::A::B::D::G") }
          it { expect(consts.resolve("::A", "::D::G")).to eq("::A::D::G") }
          it { expect(consts.resolve("", "::D::G")).to eq("::D::G") }
          it { expect(consts.resolve("::X", "::A")).to eq("::A") }
          it { expect(consts.resolve("::X::Y", "::A")).to eq("::A") }
          it { expect { consts.resolve("::A::B", "") }.to raise_error(Error) }
        end

        context "when two sources" do
          let(:sources) do
            [Source.new(location: "test1.rb", code_loader: -> { code1 }),
             Source.new(location: "test2.rb", code_loader: -> { code2 })]
          end
          let(:code1) do
            <<CODE
  module A
    module B
      class D
      end
    end
  end
CODE
          end
          let(:code2) do
            <<CODE
  module A
   allowed_dependency=B::D
  end
CODE
          end

          it { expect(consts.resolve("::A", "::B::D")).to eq("::A::B::D") }
        end
      end
    end
  end
end
