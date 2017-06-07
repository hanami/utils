require 'hanami/interactor'

class LegacyInteractorWithoutInitialize
  include Hanami::Interactor

  def call
  end
end

class InteractorWithoutInitialize
  include Hanami::Interactor

  def call(*)
  end
end

class InteractorWithoutCall
  include Hanami::Interactor
end

class InteractorWithMethodAdded
  module MethodAdded; end

  module WatchMethods
    def method_added(method_name)
      super
      include MethodAdded if method_name == :call
    end
  end

  include Hanami::Interactor
  extend WatchMethods

  def call(*)
  end
end

class User
  def initialize(attributes = {})
    @attributes = attributes
  end

  def name
    @attributes.fetch(:name, nil)
  end

  def name=(value)
    @attributes[:name] = value
  end

  def persist!
    raise if name.nil?
  end

  def to_hash
    { name: name }
  end
end

class LegacySignup
  include Hanami::Interactor
  expose :user, :params

  def initialize(params)
    @params  = params
    @user    = User.new(params)
    @__foo   = 23
  end

  def call
    @user.persist!
  rescue
    fail!
  end

  private

  def valid?
    !@params[:force_failure]
  end
end

class Signup
  include Hanami::Interactor
  expose :user, :params

  def initialize(force_failure: false)
    @force_failure = force_failure
  end

  def call(params)
    @params = params
    @user = User.new(params)
    @user.persist!
  rescue
    fail!
  end

  private

  def valid?(*)
    !@force_failure
  end
end

class LegacyErrorInteractor
  include Hanami::Interactor
  expose :operations

  def initialize
    @operations = []
  end

  def call
    prepare!
    persist!
    log!
  end

  private

  def prepare!
    @operations << __method__
    error 'There was an error while preparing data.'
  end

  def persist!
    @operations << __method__
    error 'There was an error while persisting data.'
  end

  def log!
    @operations << __method__
  end
end

class ErrorInteractor
  include Hanami::Interactor
  expose :operations

  def call(*)
    @operations = []
    prepare!
    persist!
    log!
  end

  private

  def prepare!
    @operations << __method__
    error 'There was an error while preparing data.'
  end

  def persist!
    @operations << __method__
    error 'There was an error while persisting data.'
  end

  def log!
    @operations << __method__
  end
end

class LegacyErrorBangInteractor
  include Hanami::Interactor
  expose :operations

  def initialize
    @operations = []
  end

  def call
    persist!
    sync!
  end

  private

  def persist!
    @operations << __method__
    error! 'There was an error while persisting data.'
  end

  def sync!
    @operations << __method__
    error 'There was an error while syncing data.'
  end
end

class ErrorBangInteractor
  include Hanami::Interactor
  expose :operations

  def call(*)
    @operations = []
    persist!
    sync!
  end

  private

  def persist!
    @operations << __method__
    error! 'There was an error while persisting data.'
  end

  def sync!
    @operations << __method__
    error 'There was an error while syncing data.'
  end
end

class LegacyPublishVideo
  include Hanami::Interactor

  def call
  end

  def valid?
    owns?
  end

  private

  def owns?
    # fake failed ownership check
    error("You're not owner of this video")
  end
end

class PublishVideo
  include Hanami::Interactor
  expose :video_name

  def call(*)
    @video_name = 'H2G2'
  end

  def valid?(*)
    owns?
  end

  private

  def owns?
    # fake failed ownership check
    error("You're not owner of this video")
  end
end

class LegacyCreateUser
  include Hanami::Interactor
  expose :user

  def initialize(params)
    @user = User.new(params)
  end

  def call
    persist
  end

  private

  def persist
    @user.persist!
  end
end

class CreateUser
  include Hanami::Interactor
  expose :user

  def call(**params)
    build_user(params)
    persist
  end

  private

  def build_user(params)
    @user = User.new(params)
  end

  def persist
    @user.persist!
  end
end

class LegacyUpdateUser < LegacyCreateUser
  def initialize(_user, params)
    super(params)
    @user.name = params.fetch(:name)
  end
end

class UpdateUser < CreateUser
  def build_user(user:, **params)
    @user = user
    @user.name = params.fetch(:name)
  end
end

RSpec.describe Hanami::Interactor do
  describe 'interactor interface' do
    it 'includes the correct interface' do
      expect(LegacySignup.ancestors).to include(Hanami::Interactor::LegacyInterface)
      expect(Signup.ancestors).to include(Hanami::Interactor::Interface)
    end

    it 'does not include the other interface' do
      expect(LegacySignup.ancestors).not_to include(Hanami::Interactor::Interface)
      expect(Signup.ancestors).not_to include(Hanami::Interactor::LegacyInterface)
    end

    it "raises error when #call isn't implemented" do
      expect { InteractorWithoutCall.new.call }.to raise_error NoMethodError
    end

    it 'lets .method_added open to overrides' do
      expect(InteractorWithMethodAdded.ancestors).to include(InteractorWithMethodAdded::MethodAdded)
    end
  end

  describe 'legacy interface' do
    describe '#initialize' do
      it "works when it isn't overridden" do
        LegacyInteractorWithoutInitialize.new
      end

      it 'allows to override it' do
        LegacySignup.new({})
      end
    end

    describe '#call' do
      it 'returns a result' do
        result = LegacySignup.new(name: 'Luca').call
        expect(result.class).to eq Hanami::Interactor::Result
      end

      it 'is successful by default' do
        result = LegacySignup.new(name: 'Luca').call
        expect(result).to be_successful
      end

      it 'returns the payload' do
        result = LegacySignup.new(name: 'Luca').call

        expect(result.user.name).to eq 'Luca'
        expect(result.params).to eq(name: 'Luca')
      end

      it "doesn't include private ivars" do
        result = LegacySignup.new(name: 'Luca').call

        expect { result.__foo }.to raise_error NoMethodError
      end

      it 'exposes a convenient API for handling failures' do
        result = LegacySignup.new({}).call
        expect(result).to be_failure
      end

      it "doesn't invoke it if the preconditions are failing" do
        result = LegacySignup.new(force_failure: true).call
        expect(result).to be_failure
      end

      describe 'inheritance' do
        it 'is successful for super class' do
          result = LegacyCreateUser.new(name: 'L').call

          expect(result).to be_successful
          expect(result.user.name).to eq 'L'
        end

        it 'is successful for sub class' do
          user   = User.new(name: 'L')
          result = LegacyUpdateUser.new(user, name: 'MG').call

          expect(result).to be_successful
          expect(result.user.name).to eq 'MG'
        end
      end
    end

    describe '#error' do
      it "isn't successful" do
        result = LegacyErrorInteractor.new.call
        expect(result).to be_failure
      end

      it 'accumulates errors' do
        result = LegacyErrorInteractor.new.call
        expect(result.errors).to eq [
          'There was an error while preparing data.',
          'There was an error while persisting data.'
        ]
      end

      it "doesn't interrupt the flow" do
        result = LegacyErrorInteractor.new.call
        expect(result.operations).to eq %i(prepare! persist! log!)
      end

      # See https://github.com/hanami/utils/issues/69
      it 'returns false as control flow for caller' do
        interactor = LegacyPublishVideo.new
        expect(interactor).not_to be_valid
      end
    end

    describe '#error!' do
      it "isn't successful" do
        result = LegacyErrorBangInteractor.new.call
        expect(result).to be_failure
      end

      it 'stops at the first error' do
        result = LegacyErrorBangInteractor.new.call
        expect(result.errors).to eq [
          'There was an error while persisting data.'
        ]
      end

      it 'interrupts the flow' do
        result = LegacyErrorBangInteractor.new.call
        expect(result.operations).to eq [:persist!]
      end
    end
  end

  describe 'new interface' do
    describe '#initialize' do
      it "works when it isn't overridden" do
        InteractorWithoutInitialize.new.call
      end

      it 'allows to override it' do
        Signup.new.call
      end
    end

    describe '#call' do
      it 'returns a result' do
        result = Signup.new.call(name: 'Luca')
        expect(result.class).to eq Hanami::Interactor::Result
      end

      it 'is successful by default' do
        result = Signup.new.call(name: 'Luca')
        expect(result).to be_successful
      end

      it 'returns the payload' do
        result = Signup.new.call(name: 'Luca')

        expect(result.user.name).to eq 'Luca'
        expect(result.params).to eq(name: 'Luca')
      end

      it "doesn't include private ivars" do
        result = Signup.new.call(name: 'Luca')

        expect { result.force_failure }.to raise_error NoMethodError
      end

      it 'exposes a convenient API for handling failures' do
        result = Signup.new.call
        expect(result).to be_failure
      end

      it "doesn't invoke it if the preconditions are failing" do
        result = Signup.new(force_failure: true).call
        expect(result).to be_failure
      end

      it "raises error when #call isn't implemented" do
        expect { InteractorWithoutCall.new.call }.to raise_error NoMethodError
      end

      describe 'inheritance' do
        it 'is successful for super class' do
          result = CreateUser.new.call(name: 'L')

          expect(result).to be_successful
          expect(result.user.name).to eq 'L'
        end

        it 'is successful for sub class' do
          user   = User.new(name: 'L')
          result = UpdateUser.new.call(user: user, name: 'MG')

          expect(result).to be_successful
          expect(result.user.name).to eq 'MG'
        end
      end
    end

    describe '#error' do
      it "isn't successful" do
        result = ErrorInteractor.new.call
        expect(result).to be_failure
      end

      it 'accumulates errors' do
        result = ErrorInteractor.new.call
        expect(result.errors).to eq [
          'There was an error while preparing data.',
          'There was an error while persisting data.'
        ]
      end

      it "doesn't interrupt the flow" do
        result = ErrorInteractor.new.call
        expect(result.operations).to eq %i(prepare! persist! log!)
      end

      # See https://github.com/hanami/utils/issues/69
      it 'returns false as control flow for caller' do
        result = PublishVideo.new.call
        expect(result).not_to be_successful
        expect(result.video_name).to be_nil
      end
    end

    describe '#error!' do
      it "isn't successful" do
        result = ErrorBangInteractor.new.call
        expect(result).to be_failure
      end

      it 'stops at the first error' do
        result = ErrorBangInteractor.new.call
        expect(result.errors).to eq [
          'There was an error while persisting data.'
        ]
      end

      it 'interrupts the flow' do
        result = ErrorBangInteractor.new.call
        expect(result.operations).to eq [:persist!]
      end
    end
  end
end

RSpec.describe Hanami::Interactor::Result do
  describe '#initialize' do
    it 'allows to skip payload' do
      Hanami::Interactor::Result.new
    end

    it 'accepts a payload' do
      result = Hanami::Interactor::Result.new(foo: 'bar')
      expect(result.foo).to eq 'bar'
    end
  end

  describe '#successful?' do
    it 'is successful by default' do
      result = Hanami::Interactor::Result.new
      expect(result).to be_successful
    end

    describe 'when it has errors' do
      it "isn't successful" do
        result = Hanami::Interactor::Result.new
        result.add_error 'There was a problem'
        expect(result).to be_failure
      end
    end
  end

  describe '#fail!' do
    it 'causes a failure' do
      result = Hanami::Interactor::Result.new
      result.fail!

      expect(result).to be_failure
    end
  end

  describe '#prepare!' do
    it 'merges the current payload' do
      result = Hanami::Interactor::Result.new(foo: 'bar')
      result.prepare!(foo: 23)

      expect(result.foo).to eq 23
    end

    it 'returns self' do
      result = Hanami::Interactor::Result.new(foo: 'bar')
      returning = result.prepare!(foo: 23)

      expect(returning).to eq result
    end
  end

  describe '#errors' do
    it 'empty by default' do
      result = Hanami::Interactor::Result.new
      expect(result.errors).to be_empty
    end

    it 'returns all the errors' do
      result = Hanami::Interactor::Result.new
      result.add_error ['Error 1', 'Error 2']

      expect(result.errors).to eq ['Error 1', 'Error 2']
    end

    it 'prevents information escape' do
      result = Hanami::Interactor::Result.new
      result.add_error ['Error 1', 'Error 2']

      result.errors.clear

      expect(result.errors).to eq ['Error 1', 'Error 2']
    end
  end

  describe '#error' do
    it 'nil by default' do
      result = Hanami::Interactor::Result.new
      expect(result.error).to be_nil
    end

    it 'returns only the first error' do
      result = Hanami::Interactor::Result.new
      result.add_error ['Error 1', 'Error 2']

      expect(result.error).to eq 'Error 1'
    end
  end

  describe '#respond_to?' do
    it 'returns true for concrete methods' do
      result = Hanami::Interactor::Result.new

      expect(result).to respond_to(:successful?)
      expect(result).to respond_to('successful?')

      expect(result).to respond_to(:failure?)
      expect(result).to respond_to('failure?')
    end

    it 'returns true for methods derived from payload' do
      result = Hanami::Interactor::Result.new(foo: 1)

      expect(result).to respond_to(:foo)
      expect(result).to respond_to('foo')
    end

    it 'returns true for methods derived from merged payload' do
      result = Hanami::Interactor::Result.new
      result.prepare!(bar: 2)

      expect(result).to respond_to(:bar)
      expect(result).to respond_to('bar')
    end
  end

  describe '#inspect' do
    let(:result) { Hanami::Interactor::Result.new(id: 23, user: User.new) }

    it 'reports the class name and the object_id' do
      expect(result.inspect).to match %(#<Hanami::Interactor::Result)
    end

    it 'reports the object_id' do
      object_id = format('%x', (result.__id__ << 1))
      expect(result.inspect).to match object_id
    end

    it 'reports @success' do
      expect(result.inspect).to match %(@success=true)
    end

    it 'reports @payload' do
      expect(result.inspect).to match %(@payload={:id=>23, :user=>#<User:)
    end
  end

  describe 'payload' do
    it 'returns all the values passed in the payload' do
      result = Hanami::Interactor::Result.new(a: 1, b: 2)
      expect(result.a).to eq 1
      expect(result.b).to eq 2
    end

    it 'returns hash values passed in the payload' do
      result = Hanami::Interactor::Result.new(a: { 100 => 3 })
      expect(result.a).to eq(100 => 3)
    end

    it 'returns all the values after a merge' do
      result = Hanami::Interactor::Result.new(a: 1, b: 2)
      result.prepare!(a: 23, c: 3)

      expect(result.a).to eq 23
      expect(result.b).to eq 2
      expect(result.c).to eq 3
    end

    it "doesn't ignore forwarded messages" do
      result = Hanami::Interactor::Result.new(params: { name: 'Luca' })
      expect(result.params[:name]).to eq 'Luca'
    end

    it 'raises an error when unknown message is passed' do
      result = Hanami::Interactor::Result.new
      expect { result.unknown }.to raise_error NoMethodError
    end

    it 'raises an error when unknown message is passed with args' do
      result = Hanami::Interactor::Result.new
      expect { result.unknown(:foo) }.to raise_error NoMethodError
    end
  end
end
