require 'test_helper'
require 'hanami/events'
require 'ostruct'

describe Hanami::Events do
  before do
    Hanami::Events.backend = Hanami::Events::Backends::Memory.new
  end

  describe '.subscribe' do
    it 'allows to subscribe with a proc' do
      Hanami::Events.subscribe('foo') do |event|
      end
    end

    it 'allows to subscribe with an object' do
      subscriber = ->(event) {}
      Hanami::Events.subscribe('bar', subscriber)
    end
  end

  describe '.broadcast' do
    it 'broadcasts an event' do
      mailer = Class.new do
        def call(event)
          puts "welcome email for: #{event[:user].email}"
        end
      end.new

      Hanami::Events.subscribe('signup', mailer)
      Hanami::Events.subscribe('signup') do |event|
        puts "new user signed up: #{event[:user].id}"
      end

      user = OpenStruct.new(id: 1, email: 'user@hanamirb.org')
      out, = capture_io do
        Hanami::Events.broadcast('signup', user: user)
      end

      out.must_include('welcome email for: user@hanamirb.org')
      out.must_include('new user signed up: 1')
    end
  end

  describe 'when included' do
    let(:signup) do
      Class.new do
        include Hanami::Events

        def call(input)
          user = OpenStruct.new(input)

          broadcast('welcome',          user: user)
          broadcast('analytics.update', user: user)
        end
      end
    end

    it "won't respond to .backend" do
      signup.wont_respond_to(:backend)
    end

    it "won't respond to .subscribe" do
      signup.wont_respond_to(:subscribe)
    end

    it "won't respond to .broadcast" do
      signup.wont_respond_to(:broadcast)
    end

    describe '#broadcast' do
      it 'broadcasts an event' do
        Hanami::Events.subscribe('welcome') do |event|
          puts "display welcome message for #{event[:user].id}"
        end

        Hanami::Events.subscribe('analytics.update') do |event|
          puts "update analytics for #{event[:user].id}"
        end

        out, = capture_io do
          signup.new.call(id: 23)
        end

        out.must_include('display welcome message for 23')
        out.must_include('update analytics for 23')
      end
    end
  end
end
