# frozen_string_literal: true

require "spec_helper"

module Mudguard
  RSpec.describe Mudguard do
    describe "VERSION" do
      it { expect(VERSION).not_to be nil }
    end
  end
end
