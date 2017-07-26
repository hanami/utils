require 'hanami/events'

RSpec.describe Hanami::Events do
  after { Wisper.clear }

  context '.subscribe' do
    it 'allows to subscribe with a proc' do
      expect { Hanami::Events.subscribe('user_signed_up') { |event| } }.to_not(
        raise_error
      )
    end

    it 'allows to subscribe with an object' do
      expect { Hanami::Events.subscribe('user_signed_up', ->(e) {}) }.to_not(
        raise_error
      )
    end
  end

  context '.broadcast' do
    it 'broadcasts event to single subscriber object' do
      mailer = double('mailer')

      Hanami::Events.subscribe('user_signed_up', mailer)
      expect(mailer).to receive(:call).with(id: 1, email: 'user@hanamirb.org')

      Hanami::Events.broadcast(
        'user_signed_up', id: 1, email: 'user@hanamirb.org'
      )
    end

    it 'broadcasts event to single proc subscriber' do
      Hanami::Events.subscribe('user_signed_up') do |event|
        puts "user signed up: #{event[:id]}"
      end

      expect(STDOUT).to receive(:puts).with('user signed up: 1')

      Hanami::Events.broadcast(
        'user_signed_up', id: 1, email: 'user@hanamirb.org'
      )
    end

    it 'broadcasts event to multiple subscribers' do
      mailer = double('mailer')
      analytics = double('anaytics')

      Hanami::Events.subscribe('user_signed_up', mailer)
      Hanami::Events.subscribe('user_signed_up', analytics)
      expect(mailer).to receive(:call).with(email: 'user@hanamirb.org')
      expect(analytics).to receive(:call).with(email: 'user@hanamirb.org')

      Hanami::Events.broadcast('user_signed_up', email: 'user@hanamirb.org')
    end

    it 'broadcasts multiple events to single subscriber' do
      mailer = double('mailer')

      Hanami::Events.subscribe('user_signed_up', mailer)
      Hanami::Events.subscribe('user_updated_profile', mailer)

      expect(mailer).to receive(:call).with(email: 'user@hanamirb.org').twice

      Hanami::Events.broadcast('user_signed_up', email: 'user@hanamirb.org')
      Hanami::Events.broadcast(
        'user_updated_profile', email: 'user@hanamirb.org'
      )
    end
  end

  context 'when Hanami::Events included into class' do
    let(:signup) do
      Class.new do
        include Hanami::Events

        def call(input)
          broadcast('user_signed_up', input)
        end
      end
    end

    context '#broadcast' do
      it 'broadcasts an event' do
        Hanami::Events.subscribe('user_signed_up') do |event|
          puts "welcome message for #{event[:id]}"
        end

        expect(STDOUT).to receive(:puts).with('welcome message for 23')

        signup.new.call(id: 23)
      end
    end
  end
end
