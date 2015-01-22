require 'test_helper'
require 'lotus/utils/callbacks'

Lotus::Utils::Callbacks::Chain.class_eval do
  def size
    @chain.size
  end

  def first
    @chain.first
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
    @logger = Array.new
  end

  private
  def authenticate!
    logger.push 'authenticate!'
  end

  def set_article(params)
    logger.push "set_article: #{ params[:id] }"
  end
end

describe Lotus::Utils::Callbacks::Chain do
  before do
    @chain = Lotus::Utils::Callbacks::Chain.new
  end

  describe '#append' do
    it 'wraps the given callback with a callable object' do
      @chain.append :symbolize!

      cb = @chain.first
      cb.must_respond_to(:call)
    end

    describe 'when a callable object is passed' do
      before do
        @chain.append callback
      end

      let(:callback) { Callable.new }

      it 'includes the given callback' do
        cb = @chain.first
        cb.callback.must_equal(callback)
      end
    end

    describe 'when a Symbol is passed' do
      before do
        @chain.append callback
      end

      let(:callback) { :upcase }

      it 'includes the given callback' do
        cb = @chain.first
        cb.callback.must_equal(callback)
      end

      it 'guarantees unique entries' do
        # append the callback again, see before block
        @chain.append callback
        @chain.size.must_equal(1)
      end
    end

    describe 'when a block is passed' do
      before do
        @chain.append(&callback)
      end

      let(:callback) { Proc.new{} }

      it 'includes the given callback' do
        cb = @chain.first
        assert_equal cb.callback, callback
      end
    end

    describe 'when multiple callbacks are passed' do
      before do
        @chain.append(*callbacks)
      end

      let(:callbacks) { [:upcase, Callable.new, Proc.new{}] }

      it 'includes all the given callbacks' do
        @chain.size.must_equal(callbacks.size)
      end

      it 'all the included callbacks are callable' do
        @chain.each do |callback|
          callback.must_respond_to(:call)
        end
      end
    end
  end

  describe '#run' do
    let(:action) { Action.new }
    let(:params) { Hash[id: 23] }

    describe 'when symbols are passed' do
      before do
        @chain.append :authenticate!, :set_article
        @chain.run action, params
      end

      it 'executes the callbacks' do
        authenticate = action.logger.shift
        authenticate.must_equal 'authenticate!'

        set_article = action.logger.shift
        set_article.must_equal "set_article: #{ params[:id] }"
      end
    end

    describe 'when procs are passed' do
      before do
        @chain.append do
          logger.push 'authenticate!'
        end

        @chain.append do |params|
          logger.push "set_article: #{ params[:id] }"
        end

        @chain.run action, params
      end

      it 'executes the callbacks' do
        authenticate = action.logger.shift
        authenticate.must_equal 'authenticate!'

        set_article = action.logger.shift
        set_article.must_equal "set_article: #{ params[:id] }"
      end
    end
  end

  describe '#freeze' do
    before do
      @chain.freeze
    end

    it 'must be frozen' do
      @chain.must_be :frozen?
    end

    it 'raises an error if try to add a callback when frozen' do
      -> { @chain.append :authenticate! }.must_raise RuntimeError
    end
  end
end

describe Lotus::Utils::Callbacks::Factory do
  describe '.fabricate' do
    before do
      @callback = Lotus::Utils::Callbacks::Factory.fabricate(callback)
    end

    describe 'when a callable is passed' do
      let(:callback) { Callable.new }

      it 'fabricates a Callback' do
        @callback.must_be_kind_of(Lotus::Utils::Callbacks::Callback)
      end

      it 'wraps the given callback' do
        @callback.callback.must_equal(callback)
      end
    end

    describe 'when a symbol is passed' do
      let(:callback) { :symbolize! }

      it 'fabricates a MethodCallback' do
        @callback.must_be_kind_of(Lotus::Utils::Callbacks::MethodCallback)
      end

      it 'wraps the given callback' do
        @callback.callback.must_equal(callback)
      end
    end
  end
end

describe Lotus::Utils::Callbacks::Callback do
  before do
    @callback = Lotus::Utils::Callbacks::Callback.new(callback)
  end

  let(:callback) { Proc.new{|params| logger.push("set_article: #{ params[:id] }") } }

  it 'executes self within the given context' do
    context = Action.new
    @callback.call(context, { id: 23 })

    invokation = context.logger.shift
    invokation.must_equal("set_article: 23")
  end
end

describe Lotus::Utils::Callbacks::MethodCallback do
  before do
    @callback = Lotus::Utils::Callbacks::MethodCallback.new(callback)
  end

  let(:callback) { :set_article }

  it 'executes self within the given context' do
    context = Action.new
    @callback.call(context, { id: 23 })

    invokation = context.logger.shift
    invokation.must_equal("set_article: 23")
  end

  it 'implements #hash' do
    cb = Lotus::Utils::Callbacks::MethodCallback.new(callback)
    cb.send(:hash).must_equal(@callback.send(:hash))
  end
end
