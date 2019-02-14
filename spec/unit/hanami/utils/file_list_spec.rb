# frozen_string_literal: true

require "hanami/utils/file_list"

RSpec.describe Hanami::Utils::FileList do
  describe ".[]" do
    it "returns consistent file list across operating systems" do
      list = Hanami::Utils::FileList["spec/support/fixtures/file_list/*.rb"]
      expect(list).to eq [
        "spec/support/fixtures/file_list/a.rb",
        "spec/support/fixtures/file_list/aa.rb",
        "spec/support/fixtures/file_list/ab.rb"
      ]
    end

    it "accepts multiple directory names" do
      list = Hanami::Utils::FileList["spec/support/fixtures/file_list/*.rb", "spec/support/fixtures/file_list/nested/*.rb"]
      expect(list).to eq [
        "spec/support/fixtures/file_list/a.rb",
        "spec/support/fixtures/file_list/aa.rb",
        "spec/support/fixtures/file_list/ab.rb",
        "spec/support/fixtures/file_list/nested/c.rb"
      ]
    end

    it "finds files constructing path from directory names" do
      list = Hanami::Utils::FileList["spec", "support", "fixtures", "file_list", "*.rb"]
      expect(list).to eq [
        "spec/support/fixtures/file_list/a.rb",
        "spec/support/fixtures/file_list/aa.rb",
        "spec/support/fixtures/file_list/ab.rb"
      ]
    end
  end
end
