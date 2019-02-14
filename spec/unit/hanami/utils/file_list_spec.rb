# frozen_string_literal: true

require "hanami/utils/file_list"
require "pathname"

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

    it "finds files constructing path from directory names" do
      list = Hanami::Utils::FileList["spec", "support", "fixtures", "file_list", "*.rb"]
      expect(list).to eq [
        "spec/support/fixtures/file_list/a.rb",
        "spec/support/fixtures/file_list/aa.rb",
        "spec/support/fixtures/file_list/ab.rb"
      ]
    end

    it "accepts Pathname as argument" do
      list = Hanami::Utils::FileList[Pathname("spec/support/fixtures/file_list/*.rb")]
      expect(list).to eq [
        "spec/support/fixtures/file_list/a.rb",
        "spec/support/fixtures/file_list/aa.rb",
        "spec/support/fixtures/file_list/ab.rb"
      ]
    end

    it "accepts root directory and path tokens" do
      root = Pathname(Dir.pwd).realpath
      list = Hanami::Utils::FileList[root, "spec", "support", "fixtures", "file_list", "*.rb"]
      expect(list).to eq [
        root.join("spec/support/fixtures/file_list/a.rb").to_s,
        root.join("spec/support/fixtures/file_list/aa.rb").to_s,
        root.join("spec/support/fixtures/file_list/ab.rb").to_s
      ]
    end
  end
end
