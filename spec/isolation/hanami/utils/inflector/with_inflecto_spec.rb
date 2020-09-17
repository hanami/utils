# frozen_string_literal: true

require_relative __dir__ + "../../../../../support/isolation_spec_helper"
Bundler.require(:default, :development, :inflecto)
require "hanami/utils/inflector"
require "inflecto"

RSpec.describe Hanami::Utils::Inflector do
  describe ".exception" do
    context "with inflecto" do
      it "registers Inflecto exception" do
        # just some weird Portuguese pluralization rules
        described_class.exception("poção", "poções")

        expect(Inflecto.pluralize("poção")).to eq("poções")
        expect(Inflecto.singularize("poções")).to eq("poção")
      end
    end
  end
end

RSpec::Support::Runner.run
