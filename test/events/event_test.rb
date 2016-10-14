require 'test_helper'
require 'hanami/events'
require 'hanami/utils/hash'

describe Hanami::Events::Event do
  let(:described_class) { Hanami::Events::Event }

  describe '#initialize' do
    it 'accepts Hash' do
      payload = { a: 1 }
      event   = described_class.new(payload)

      event[:a].must_equal(1)
    end

    it 'accepts Hanami::Utils::Hash' do
      payload = Hanami::Utils::Hash.new(a: 1)
      event   = described_class.new(payload)

      event[:a].must_equal(1)
    end

    it 'accepts #to_h' do
      payload = Class.new do
        def to_h
          { a: 1 }
        end
      end.new

      event = described_class.new(payload)

      event[:a].must_equal(1)
    end

    it 'accepts #to_hash' do
      payload = Class.new do
        def to_hash
          { a: 1 }
        end
      end.new

      event = described_class.new(payload)

      event[:a].must_equal(1)
    end

    it 'symbolizes keys' do
      payload = { 'a' => 1 }
      event   = described_class.new(payload)

      event[:a].must_equal(1)
    end

    it 'freezes payload' do
      payload = { a: [1, 2, 3] }
      event   = described_class.new(payload)

      lambda do
        event[:a].push(4)
      end.must_raise(RuntimeError)
    end
  end

  describe '#[]' do
    it 'returns value' do
      event = described_class.new(a: 1)

      event[:a].must_equal(1)
    end

    it "doesn't allow indifferent access" do
      event = described_class.new(a: 1)

      event['a'].must_equal(nil)
    end

    it 'returns nil for unknown key' do
      event = described_class.new(a: 1)

      event[:unknown].must_equal(nil)
    end
  end
end
