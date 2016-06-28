require 'test_helper'
require 'hanami/configuration'

module Controllers
  class Configuration < Hanami::Configuration
    setting :foo, true
  end

  def self.configuration
    Configuration.new
  end

  class Action
  end
end

describe Hanami::Configuration do
  before do
    @config = Class.new(Hanami::Configuration) do
      setting :handle_exceptions
      setting :handled_exceptions, {}
    end

    @other = Class.new(Hanami::Configuration) do
    end
  end

  describe '.setting' do
    it 'defines a getter' do
      config = @config.new

      config.must_respond_to(:handle_exceptions)
      config.handle_exceptions.must_equal nil
    end

    it 'allows to set a default' do
      @config.new.handled_exceptions.must_equal({})
    end

    it "doesn't define a getter in other configurations" do
      @other.new.wont_respond_to(:handle_exceptions)
    end

    it "doesn't define a setter if the :writer option is false" do
      config = Class.new(Hanami::Configuration) do
        setting :raise_errors, true, writer: false
      end

      config.new.wont_respond_to(:raise_errors=)
      config.new.must_respond_to(:raise_errors)
    end

    it "doesn't define a getter if the :reader option is false" do
      config = Class.new(Hanami::Configuration) do
        setting :raise_errors, true, reader: false
      end

      config.new.must_respond_to(:raise_errors=)
      config.new.wont_respond_to(:raise_errors)
    end
  end

  describe '.for' do
    describe 'with anonymous module' do
      before do
        klass  = nil
        @mod   = Module.new do
          @configuration = Class.new(Hanami::Configuration)

          def self.configuration
            @configuration
          end

          klass = Class.new
        end

        @klass = klass
      end

      it 'returns the configuration' do
        config = @mod.configuration.for(@klass)
        config.must_be_kind_of(@mod.configuration)
      end
    end

    describe 'with concrete module' do
      it 'returns the configuration' do
        config = Controllers::Configuration.for(Controllers::Action)
        config.must_be_kind_of(Controllers::Configuration)
      end
    end
  end

  describe '.fabricate' do
    it 'returns given configuration' do
      configuration = Controllers::Configuration.new(foo: 23)
      actual        = Controllers::Configuration.fabricate(configuration)

      actual.must_equal(configuration)
      actual.object_id.must_equal(configuration.object_id)
    end

    it 'initializes a configuration for the given hash' do
      configuration = Hash[foo: 'ok']
      actual        = Controllers::Configuration.fabricate(configuration)

      actual.must_be_kind_of(Controllers::Configuration)
      actual.foo.must_equal 'ok'
    end

    it "raises TypeError when the object isn't a hash" do
      configuration = Object.new
      -> { Controllers::Configuration.fabricate(configuration) }.must_raise TypeError
    end
  end

  describe '#initialize' do
    it 'accepts a block to define settings' do
      config = @config.new do |c|
        c.handle_exceptions = true
      end

      config.handle_exceptions.must_equal(true)
    end

    it 'keeps separated values from different instances' do
      config1 = @config.new do |c|
        c.handle_exceptions = true
      end

      config2 = @config.new do |c|
        c.handle_exceptions = false
      end

      config1.handle_exceptions.must_equal(true)
      config2.handle_exceptions.must_equal(false)
    end

    it 'keeps separated values from class settings' do
      config1 = @config.new do |c|
        c.handle_exceptions = true
      end

      config2 = @config.new

      config1.handle_exceptions.must_equal(true)
      config2.handle_exceptions.must_equal(nil)
    end

    it 'keeps separated values from class settings when setting is passed by reference' do
      config1 = @config.new do |c|
        c.handled_exceptions[ArgumentError] = 404
      end

      config2 = @config.new

      config1.handled_exceptions.must_equal(ArgumentError => 404)
      config2.handled_exceptions.must_equal({})
    end

    it 'freezes after initialization' do
      exception = -> { @config.new.handle_exceptions = false }.must_raise RuntimeError
      exception.message.must_equal "can't modify frozen Hash"
    end

    it 'deep freezes objects passed by reference' do
      exception = -> { @config.new.handled_exceptions[StandardError] = 500 }.must_raise RuntimeError
      exception.message.must_equal "can't modify frozen Hash"
    end
  end

  describe '#configure' do
    it 'instantiates a new configuration and yields the given block' do
      config = Controllers::Configuration.new
      actual = config.configure do |c|
        c.foo = false
      end

      config.foo.must_equal(true)
      actual.foo.must_equal(false)

      actual.wont_equal(config)
      actual.object_id.wont_equal(config.object_id)
    end
  end
end
