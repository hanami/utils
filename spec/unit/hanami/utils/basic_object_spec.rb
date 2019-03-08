require 'hanami/utils/basic_object'
require 'pp'

class TestClass < Hanami::Utils::BasicObject
end

RSpec.describe Hanami::Utils::BasicObject do
  describe '#respond_to_missing?' do
    it 'raises an exception if respond_to? method is not implemented' do
      expect { TestClass.new.respond_to?(:no_existing_method) }
        .to raise_error(NotImplementedError)
    end

    it 'returns true given respond_to? method was implemented' do
      TestCase = Class.new(TestClass) do
        def respond_to?(_method_name, _include_all = false)
          true
        end
      end

      expect(TestCase.new).to respond_to(:no_existing_method)
    end
  end

  describe '#class' do
    it 'returns TestClass' do
      expect(TestClass.new.class).to eq TestClass
    end
  end

  describe '#inspect' do
    it 'returns the inspect message' do
      inspect_msg = TestClass.new.inspect
      expect(inspect_msg).to match(/\A#<TestClass:\w+>\z/)
    end
  end

  describe "#pretty_print" do
    # See https://github.com/hanami/hanami/issues/629
    it 'is pretty printable' do
      expect { pp TestClass.new }.to output(/TestClass/).to_stdout
    end

    # See https://github.com/hanami/utils/issues/234
    it "outputs the inspection to the given printer" do
      printer = PP.new
      subject = TestClass.new
      subject.pretty_print(printer)

      expect(printer.output).to match(/\A#<TestClass:\w+>\z/)
    end
  end

  describe '#instance_of?' do
    subject { object.instance_of?(TestClass) }

    context 'when object is instance of the given class' do
      let(:object) { TestClass.new }

      it { is_expected.to eq(true) }
    end

    context 'when object is not instance of the given class' do
      let(:object) { 'not_test_class' }

      it { is_expected.to eq(false) }
    end
  end

  shared_examples 'is_a?' do
    let(:test_class) { TestClass }
    subject { eval("object.#{method_name}(test_class)") }

    context 'when object is instance of the given class' do
      let(:object) { test_class.new }

      it { is_expected.to eq(true) }
    end

    context 'when object is instance of the subclass' do
      let(:object) { Class.new(test_class).new }

      it { is_expected.to eq(true) }
    end

    context 'when object has given module included' do
      let(:test_class) { Module.new }
      let(:object) do
        mdl = test_class
        Class.new do
          include mdl
        end.new
      end

      it { is_expected.to eq(true) }
    end
  end

  describe('#is_a?') do
    let(:method_name) { 'is_a?' }
    it_behaves_like 'is_a?'
  end

  describe('#kind_of?') do
    let(:method_name) { 'kind_of?' }
    it_behaves_like 'is_a?'
  end
end
