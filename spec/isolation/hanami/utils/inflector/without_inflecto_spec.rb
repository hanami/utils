# frozen_string_literal: true

require_relative __dir__ + "../../../../../support/isolation_spec_helper"
Bundler.require(:default, :development)
require "hanami/utils/inflector"

RSpec.describe Hanami::Utils::Inflector do
  describe ".exception" do
    context "without inflecto" do
      it "registers exception" do
        expect { described_class.exception("receita", "receitas") }.to_not raise_error

        expect(described_class.pluralize("receita")).to eq("receitas")
        expect(described_class.singularize("receitas")).to eq("receita")
      end
    end
  end
end

RSpec::Support::Runner.run
