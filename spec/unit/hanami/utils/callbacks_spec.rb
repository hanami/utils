require "hanami/utils/callbacks"

Hanami::Utils::Callbacks::Chain.class_eval do
  def size
    @chain.size
  end

  def first
    @chain.first
  end

  def last
    @chain.last
  end

  def each(&blk)
    @chain.each(&blk)
  end
end

class Callable
  def call
  end
end

class Action
  attr_reader :logger

  def initialize
    @logger = []
  end

  private

  def authenticate!
    logger.push "authenticate!"
  end

  def set_article(params) # rubocop:disable Naming/AccessorMethodName
    logger.push "set_article: #{params[:id]}"
  end
end

RSpec.describe Hanami::Utils::Callbacks::Chain do
  before do
    @chain = Hanami::Utils::Callbacks::Chain.new
  end

  describe "#append" do
    it "wraps the given callback with a callable object" do
      @chain.append :symbolize!

      cb = @chain.last
      expect(cb).to respond_to(:call)
    end

    it "appends the callbacks at the end of the chain" do
      @chain.append(:foo)

      @chain.append(:bar)
      expect(@chain.first.callback).to eq(:foo)
      expect(@chain.last.callback).to eq(:bar)
    end

    describe "when a callable object is passed" do
      before do
        @chain.append callback
      end

      let(:callback) { Callable.new }

      it "includes the given callback" do
        cb = @chain.last
        expect(cb.callback).to eq(callback)
      end
    end

    describe "when a Symbol is passed" do
      before do
        @chain.append callback
      end

      let(:callback) { :upcase }

      it "includes the given callback" do
        cb = @chain.last
        expect(cb.callback).to eq(callback)
      end

      it "guarantees unique entries" do
        # append the callback again, see before block
        @chain.append callback
        expect(@chain.size).to eq(1)
      end
    end

    describe "when a block is passed" do
      before do
        @chain.append(&callback)
      end

      let(:callback) { proc {} }

      it "includes the given callback" do
        cb = @chain.last
        expect(cb.callback).to eq(callback)
      end
    end

    describe "when multiple callbacks are passed" do
      before do
        @chain.append(*callbacks)
      end

      let(:callbacks) { [:upcase, Callable.new, proc {}] }

      it "includes all the given callbacks" do
        expect(@chain.size).to eq(callbacks.size)
      end

      it "all the included callbacks are callable" do
        @chain.each do |callback|
          expect(callback).to respond_to(:call)
        end
      end
    end
  end

  describe "#prepend" do
    it "wraps the given callback with a callable object" do
      @chain.prepend :symbolize!

      cb = @chain.first
      expect(cb).to respond_to(:call)
    end

    it "prepends the callbacks at the beginning of the chain" do
      @chain.append(:foo)

      @chain.prepend(:bar)
      expect(@chain.first.callback).to eq(:bar)
      expect(@chain.last.callback).to eq(:foo)
    end

    describe "when a callable object is passed" do
      before do
        @chain.prepend callback
      end

      let(:callback) { Callable.new }

      it "includes the given callback" do
        cb = @chain.first
        expect(cb.callback).to eq(callback)
      end
    end

    describe "when a Symbol is passed" do
      before do
        @chain.prepend callback
      end

      let(:callback) { :upcase }

      it "includes the given callback" do
        cb = @chain.first
        expect(cb.callback).to eq(callback)
      end

      it "guarantees unique entries" do
        # append the callback again, see before block
        @chain.prepend callback
        expect(@chain.size).to eq(1)
      end
    end

    describe "when a block is passed" do
      before do
        @chain.prepend(&callback)
      end

      let(:callback) { proc {} }

      it "includes the given callback" do
        cb = @chain.first
        expect(cb.callback).to eq callback
      end
    end

    describe "when multiple callbacks are passed" do
      before do
        @chain.prepend(*callbacks)
      end

      let(:callbacks) { [:upcase, Callable.new, proc {}] }

      it "includes all the given callbacks" do
        expect(@chain.size).to eq(callbacks.size)
      end

      it "all the included callbacks are callable" do
        @chain.each do |callback|
          expect(callback).to respond_to(:call)
        end
      end
    end
  end

  describe "#run" do
    let(:action) { Action.new }
    let(:params) { Hash[id: 23] }

    describe "when symbols are passed" do
      before do
        @chain.append :authenticate!, :set_article
        @chain.run action, params
      end

      it "executes the callbacks" do
        authenticate = action.logger.shift
        expect(authenticate).to eq "authenticate!"

        set_article = action.logger.shift
        expect(set_article).to eq "set_article: #{params[:id]}"
      end
    end

    describe "when procs are passed" do
      before do
        @chain.append do
          logger.push "authenticate!"
        end

        @chain.append do |params|
          logger.push "set_article: #{params[:id]}"
        end

        @chain.run action, params
      end

      it "executes the callbacks" do
        authenticate = action.logger.shift
        expect(authenticate).to eq "authenticate!"

        set_article = action.logger.shift
        expect(set_article).to eq "set_article: #{params[:id]}"
      end
    end
  end

  describe "#dup" do
    let(:action) { Action.new }

    it "duplicates chain" do
      duplicated = @chain.dup

      @chain.append do
        logger.push "original chain"
      end

      duplicated.append do
        logger.push "duplicated chain"
      end

      @chain.run(action)
      expect(action.logger).to eq(["original chain"])
    end
  end

  describe "#freeze" do
    before do
      @chain.freeze
    end

    it "must be frozen" do
      expect(@chain).to be_frozen
    end

    it "raises an error if try to add a callback when frozen" do
      expect { @chain.append :authenticate! }.to raise_error RuntimeError
    end
  end

  describe "#==" do
    it "is equal to another chain based on its contents" do
      @chain.append :callback_a, :callback_b

      other = @chain.class.new
      other.append :callback_a, :callback_b

      expect(@chain).to eq other
    end
  end
end

RSpec.describe Hanami::Utils::Callbacks::Factory do
  describe ".fabricate" do
    before do
      @callback = Hanami::Utils::Callbacks::Factory.fabricate(callback)
    end

    describe "when a callable is passed" do
      let(:callback) { Callable.new }

      it "fabricates a Callback" do
        expect(@callback).to be_kind_of(Hanami::Utils::Callbacks::Callback)
      end

      it "wraps the given callback" do
        expect(@callback.callback).to eq(callback)
      end
    end

    describe "when a symbol is passed" do
      let(:callback) { :symbolize! }

      it "fabricates a MethodCallback" do
        expect(@callback).to be_kind_of(Hanami::Utils::Callbacks::MethodCallback)
      end

      it "wraps the given callback" do
        expect(@callback.callback).to eq(callback)
      end
    end
  end
end

RSpec.describe Hanami::Utils::Callbacks::Callback do
  before do
    @callback = Hanami::Utils::Callbacks::Callback.new(callback)
  end

  let(:callback) { proc { |params| logger.push("set_article: #{params[:id]}") } }

  it "executes self within the given context" do
    context = Action.new
    @callback.call(context, id: 23)

    invokation = context.logger.shift
    expect(invokation).to eq("set_article: 23")
  end
end

RSpec.describe Hanami::Utils::Callbacks::MethodCallback do
  before do
    @callback = Hanami::Utils::Callbacks::MethodCallback.new(callback)
  end

  let(:callback) { :set_article }

  it "executes self within the given context" do
    context = Action.new
    @callback.call(context, id: 23)

    invokation = context.logger.shift
    expect(invokation).to eq("set_article: 23")
  end

  it "implements #hash" do
    cb = Hanami::Utils::Callbacks::MethodCallback.new(callback)
    expect(cb.send(:hash)).to eq(@callback.send(:hash))
  end
end
