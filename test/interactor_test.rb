require 'test_helper'
require 'lotus/interactor'

class InteractorWithoutInitialize
  include Lotus::Interactor

  def call
  end
end

class InteractorWithoutCall
  include Lotus::Interactor
end

class User
  def initialize(attributes = {})
    @attributes = attributes
  end

  def name
    @attributes.fetch(:name, nil)
  end

  def persist!
    raise if name.nil?
  end
end

class Signup
  include Lotus::Interactor

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

class ErrorInteractor
  include Lotus::Interactor

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
    error "There was an error while preparing data."
  end

  def persist!
    @operations << __method__
    error "There was an error while persisting data."
  end

  def log!
    @operations << __method__
  end
end

class ErrorBangInteractor
  include Lotus::Interactor

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
    error! "There was an error while persisting data."
  end

  def sync!
    @operations << __method__
    error "There was an error while syncing data."
  end
end

class PublishVideo
  include Lotus::Interactor

  def call
  end

  def valid?
    owns?
  end

  private
  def owns?
    # fake failed ownership check
    1 == 0 or
      error "You're not owner of this video"
  end
end

describe Lotus::Interactor do
  describe '#initialize' do
    it "works when it isn't overridden" do
      InteractorWithoutInitialize.new
    end

    it "allows to override it" do
      Signup.new({})
    end
  end

  describe '#call' do
    it "returns a result" do
      result = Signup.new(name: 'Luca').call
      assert result.class == Lotus::Interactor::Result, "Expected `result' to be kind of `Lotus::Interactor::Result'"
    end

    it "is successful by default" do
      result = Signup.new(name: 'Luca').call
      assert result.success?, "Expected `result' to be successful"
    end

    it "returns the payload" do
      result = Signup.new(name: 'Luca').call

      result.user.name.must_equal 'Luca'
      result.params.must_equal({name: 'Luca'})
    end

    it "doesn't include private ivars" do
      result = Signup.new(name: 'Luca').call

      -> { result.__foo }.must_raise NoMethodError
    end

    it "exposes a convenient API for handling failures" do
      result = Signup.new({}).call
      assert !result.success?, "Expected `result' to NOT be successful"
    end

    it "doesn't invoke it if the preconditions are failing" do
      result = Signup.new({force_failure: true}).call
      assert !result.success?, "Expected `result' to NOT be successful"
    end

    it "raises error when #call isn't implemented" do
      -> { InteractorWithoutCall.new.call }.must_raise NoMethodError
    end
  end

  describe "#error" do
    it "isn't successful" do
      result = ErrorInteractor.new.call
      assert !result.success?, "Expected `result' to not be successful"
    end

    it "accumulates errors" do
      result = ErrorInteractor.new.call
      result.errors.must_equal [
        "There was an error while preparing data.",
        "There was an error while persisting data."
      ]
    end

    it "doesn't interrupt the flow" do
      result = ErrorInteractor.new.call
      result.operations.must_equal [:prepare!, :persist!, :log!]
    end

    # See https://github.com/lotus/utils/issues/69
    it 'returns false as control flow for caller' do
      interactor = PublishVideo.new
      assert !interactor.valid?, "Expected interactor to not be valid"
    end
  end

  describe "#error!" do
    it "isn't successful" do
      result = ErrorBangInteractor.new.call
      assert !result.success?, "Expected `result' to not be successful"
    end

    it "stops at the first error" do
      result = ErrorBangInteractor.new.call
      result.errors.must_equal [
        "There was an error while persisting data."
      ]
    end

    it "interrupts the flow" do
      result = ErrorBangInteractor.new.call
      result.operations.must_equal [:persist!]
    end
  end
end

describe Lotus::Interactor::Result do
  describe '#initialize' do
    it 'allows to skip payload' do
      Lotus::Interactor::Result.new
    end

    it 'accepts a payload' do
      result = Lotus::Interactor::Result.new(foo: 'bar')
      result.foo.must_equal 'bar'
    end
  end

  describe '#success?' do
    it 'is successful by default' do
      result = Lotus::Interactor::Result.new
      assert result.success?, "Expected `result' to be successful"
    end

    describe "when it has errors" do
      it "isn't successful" do
        result = Lotus::Interactor::Result.new
        result.prepare!(_errors: ["There was a problem"])
        assert !result.success?, "Expected `result' to NOT be successful"
      end
    end
  end

  describe '#fail!' do
    it 'causes a failure' do
      result = Lotus::Interactor::Result.new
      result.fail!

      assert !result.success?, "Expected `result' to NOT be successful"
    end
  end

  describe '#prepare!' do
    it 'merges the current payload' do
      result = Lotus::Interactor::Result.new(foo: 'bar')
      result.prepare!(foo: 23)

      result.foo.must_equal 23
    end

    it 'returns self' do
      result = Lotus::Interactor::Result.new(foo: 'bar')
      returning = result.prepare!(foo: 23)

      assert returning == result, "Expected `returning' to equal `result'"
    end
  end

  describe "#errors" do
    it "empty by default" do
      result = Lotus::Interactor::Result.new
      result.errors.must_be :empty?
    end

    it "returns all the errors" do
      result = Lotus::Interactor::Result.new
      result.prepare!(_errors: ['Error 1', 'Error 2'])

      result.errors.must_equal ['Error 1', 'Error 2']
    end
  end

  describe "#error" do
    it "nil by default" do
      result = Lotus::Interactor::Result.new
      result.error.must_be_nil
    end

    it "returns only the first error" do
      result = Lotus::Interactor::Result.new
      result.prepare!(_errors: ['Error 1', 'Error 2'])

      result.error.must_equal 'Error 1'
    end
  end

  describe '#respond_to?' do
    it 'returns true for concrete methods' do
      result = Lotus::Interactor::Result.new

      assert result.respond_to?(:success?),  "Expected `result' to respond to `#success?'"
      assert result.respond_to?('success?'), "Expected `result' to respond to `#success?'"
    end

    it 'returns true for methods derived from payload' do
      result = Lotus::Interactor::Result.new(foo: 1)

      assert result.respond_to?(:foo),  "Expected `result' to respond to `#foo'"
      assert result.respond_to?('foo'), "Expected `result' to respond to `#foo'"
    end

    it 'returns true for methods derived from merged payload' do
      result = Lotus::Interactor::Result.new
      result.prepare!('bar' => 2)

      assert result.respond_to?(:bar),  "Expected `result' to respond to `#bar'"
      assert result.respond_to?('bar'), "Expected `result' to respond to `#bar'"
    end
  end

  describe '#inspect' do
    let(:result) { Lotus::Interactor::Result.new(id: 23, user: User.new) }

    it 'reports the class name and the object_id' do
      result.inspect.must_match %(#<Lotus::Interactor::Result)
    end

    it 'reports the object_id' do
      object_id = "%x" % (result.__id__ << 1)
      result.inspect.must_match object_id
    end

    it 'reports @success' do
      result.inspect.must_match %(@success=true)
    end

    it 'reports @payload' do
      result.inspect.must_match %(@payload={:id=>23, :user=>#<User:)
    end
  end

  describe 'payload' do
    it 'returns all the values passed in the payload' do
      result = Lotus::Interactor::Result.new(a: 1, b: 2)
      result.a.must_equal 1
      result.b.must_equal 2
    end

    it 'returns all the values after a merge' do
      result = Lotus::Interactor::Result.new(a: 1, b: 2)
      result.prepare!(a: 23, c: 3)

      result.a.must_equal 23
      result.b.must_equal 2
      result.c.must_equal 3
    end

    it "doesn't ignore forwarded messages" do
      result = Lotus::Interactor::Result.new(params: {name: 'Luca'})
      result.params[:name].must_equal 'Luca'
    end

    it 'raises an error when unknown message is passed' do
      result = Lotus::Interactor::Result.new
      -> { result.unknown }.must_raise NoMethodError
    end

    it 'raises an error when unknown message is passed with args' do
      result = Lotus::Interactor::Result.new
      -> { result.unknown(:foo) }.must_raise NoMethodError
    end
  end
end
