# frozen_string_literal: true

require "hanami/utils/class_attribute/attributes"

RSpec.describe Hanami::Utils::ClassAttribute::Attributes do
  subject { described_class.new }

  describe "#initialize" do
    it "returns a new instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#[]=" do
    it "sets value for given key" do
      subject["foo"] = 1
      subject[:bar]  = 2

      expect(subject[:foo]).to eq(1)
      expect(subject[:bar]).to eq(2)
    end
  end

  describe "#[]" do
    it "gets value for given key" do
      subject[:foo] = 1

      expect(subject[:foo]).to eq(1)
      expect(subject["foo"]).to be(nil)
    end
  end

  describe "#dup" do
    it "returns a duplicated instance" do
      duplicated = subject.dup

      expect(duplicated).to be_kind_of(described_class)
      expect(duplicated.object_id).to_not eq(subject.object_id)
    end

    it "returns duplicated values" do
      subject[:foo] = original_value = [1, 2, 3]
      duplicated = subject.dup

      duplicated[:foo] << 4
      expect(subject[:foo]).to eq(original_value)
    end
  end
end
