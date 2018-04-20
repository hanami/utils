require "hanami/result"

RSpec.describe Hanami::Result do
  describe "#initialize" do
    it "can be initialized without data" do
      subject = described_class.new
      expect(subject).to be_kind_of(described_class)
    end

    it "can be initialized with data" do
      subject = described_class.new(foo: "bar")
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#[]=" do
    it "allows to mutate the payload" do
      subject = described_class.new
      subject[:foo] = "bar"

      expect(subject[:foo]).to eq("bar")
    end

    it "allows to override given payload" do
      subject = described_class.new(foo: "bar")
      subject[:foo] = "hello"

      expect(subject[:foo]).to eq("hello")
    end
  end

  describe "#[]" do
    it "allows to access payload" do
      subject = described_class.new(foo: "bar")
      expect(subject[:foo]).to eq("bar")
    end

    it "returns nil when key isn't known" do
      subject = described_class.new(foo: "bar")
      expect(subject["foo"]).to be(nil)
    end
  end

  describe "#result" do
    it "returns Success by default" do
      subject = described_class.new
      expect(subject.result).to be_kind_of(Hanami::Success)
    end
  end

  describe "#fail" do
    it "can be turned into a failure" do
      subject = described_class.new(foo: "bar")
      result  = subject.fail(messages = ["foo can't equal bar", "foo must be a number"])

      expect(result).to be_kind_of(Hanami::Failure)
      expect(result[:foo]).to eq("bar")
      expect(result.messages).to eq(messages)
    end
  end

  describe "#error" do
    it "can be turned into an error" do
      result = described_class.new(foo: "bar")
      subject = result.error(exception = ArgumentError.new, code: code = :authentication_failed, message: message = "can't access this resource")

      expect(subject).to be_kind_of(Hanami::Error)
      expect(subject.exception).to eq(exception)
      expect(subject.code).to eq(code)
      expect(subject.message).to eq(message)
    end
  end
end

RSpec.describe Hanami::Success do
  describe "#initialize" do
    it "can be initialized without data" do
      subject = described_class.new
      expect(subject).to be_kind_of(described_class)
    end

    it "can be initialized with data" do
      subject = described_class.new(foo: "bar")
      expect(subject).to be_kind_of(described_class)
    end

    it "freezes the object" do
      subject = described_class.new
      expect(subject.frozen?).to be(true)
    end
  end

  describe "#[]" do
    it "allows to access payload" do
      subject = described_class.new(foo: "bar")
      expect(subject[:foo]).to eq("bar")
    end

    it "returns nil when key isn't known" do
      subject = described_class.new(foo: "bar")
      expect(subject["foo"]).to be(nil)
    end
  end
end

RSpec.describe Hanami::Failure do
  describe "#initialize" do
    it "can be initialized without data" do
      subject = described_class.new
      expect(subject).to be_kind_of(described_class)
    end

    it "can be initialized with data" do
      subject = described_class.new(foo: "bar")
      expect(subject).to be_kind_of(described_class)
    end

    it "can be initialized with data and messages" do
      subject = described_class.new(expected = ["user is invalid", "password doesn't match"], foo: "bar")
      expect(subject.messages).to eq(expected)
      expect(subject.message).to eq(expected.first)
      expect(subject[:foo]).to eq("bar")
    end

    it "is frozen" do
      subject = described_class.new
      expect(subject.frozen?).to be(true)
    end

    it "accepts messages" do
      subject = described_class.new("user is invalid", "password doesn't match")
      expect(subject).to be_kind_of(described_class)
    end

    it "accepts message" do
      subject = described_class.new("user is invalid")
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#messages" do
    it "allows to access messages" do
      subject = described_class.new(expected = ["user is invalid", "password doesn't match"])
      expect(subject.messages).to eq(expected)
    end

    it "returns empty messages" do
      subject = described_class.new
      expect(subject.messages).to eq([])
    end
  end

  describe "#message" do
    it "allows to access message" do
      subject = described_class.new(expected = "user is invalid", "password doesn't match")
      expect(subject.message).to eq(expected)
    end

    it "returns nil" do
      subject = described_class.new
      expect(subject.message).to eq(nil)
    end
  end

  describe "#[]" do
    it "allows to access payload" do
      subject = described_class.new(foo: "bar")
      expect(subject[:foo]).to eq("bar")
    end

    it "returns nil when key isn't known" do
      subject = described_class.new(foo: "bar")
      expect(subject["foo"]).to eq(nil)
    end
  end
end

RSpec.describe Hanami::Error do
  describe "#initialize" do
    it "accepts an exception" do
      subject = described_class.new(ArgumentError.new)
      expect(subject).to be_kind_of(described_class)
    end

    it "is frozen" do
      subject = described_class.new(ArgumentError.new)
      expect(subject.frozen?).to be(true)
    end

    it "allows to specify custom error message" do
      subject = described_class.new(ArgumentError.new("arggghh"), message: message = "there was a problem")
      expect(subject.message).to eq(message)
    end

    it "allows to specify custom error code" do
      subject = described_class.new(ArgumentError.new, code: code = :authentication_failed)
      expect(subject.code).to eq(code)
    end
  end

  describe "#exception" do
    it "wraps exception" do
      subject = described_class.new(exception = ArgumentError.new)
      expect(subject.exception).to eq(exception)
    end
  end

  describe "#message" do
    it "has default error message from the exception" do
      subject = described_class.new(exception = ArgumentError.new)
      expect(subject.message).to eq(exception.message)
    end
  end

  describe "#code" do
    it "has default error code" do
      subject = described_class.new(ArgumentError.new)
      expect(subject.code).to eq(:error)
    end
  end

  describe "#backtrace" do
    it "it returns exception backtrace" do
      subject = described_class.new(exception = ArgumentError.new)
      expect(subject.backtrace).to eq(exception.backtrace)
    end
  end
end
