require 'test_helper'
require 'set'
require 'bigdecimal'
require 'hanami/utils/freezable'
require 'hanami/utils/hash'

describe Hanami::Utils::Freezable do
  describe ".freeze" do
    describe "non freezable types" do
      it "doesn't freeze class" do
        assert_unfrozen String
      end

      it "doesn't freeze anonymous class" do
        assert_unfrozen Class.new
      end

      it "doesn't freeze module" do
        assert_unfrozen Hanami::Utils
      end

      it "doesn't freeze anonymous module" do
        assert_unfrozen Module.new
      end
    end

    describe "already frozen types" do
      it "freezes nil" do
        assert_frozen nil
      end

      it "freezes false" do
        assert_frozen false
      end

      it "freezes true" do
        assert_frozen true
      end

      it "freezes symbol" do
        assert_frozen :hanami
      end

      it "freezes integer" do
        assert_frozen 23
      end

      it "freezes float" do
        assert_frozen 3.14
      end

      it "freezes bigdecimal" do
        assert_frozen BigDecimal.new(42)
      end

      it "freezes bignum" do
        assert_frozen 70207105185500 ** 64
      end

      it "freezes date" do
        assert_frozen Date.today
      end

      it "freezes time" do
        assert_frozen Time.now
      end

      it "freezes datetime" do
        assert_frozen DateTime.now
      end
    end

    describe "freezable types" do
      it "freezes string" do
        assert_frozen "Hanami"
      end

      describe 'Array' do
        it "freezes array" do
          assert_frozen [2, [3, 'L']]
        end

        it "deeply freezes array" do
          array = freeze([2, [3, 'L']])

          array.each do |e|
            e.must_be(:frozen?)
          end
        end
      end

      describe 'Set' do
        it "freezes set" do
          assert_frozen Set.new(['L'])
        end

        it "deeply freezes set" do
          set = freeze(Set.new(['L', [1]]))

          set.each do |e|
            e.must_be(:frozen?)
          end
        end
      end

      describe 'Hash' do
        it "freezes hash" do
          assert_frozen Hash['L' => 23]
        end

        it "deeply freezes hash" do
          hash = freeze(Hash['settings' => { a: '1' }])

          hash.each_value do |v|
            v.must_be(:frozen?)
          end
        end
      end

      describe 'Hanami::Utils::Hash' do
        it "freezes hash" do
          assert_frozen Hanami::Utils::Hash.new('L' => 23)
        end

        it "deeply freezes hash" do
          hash = freeze(Hanami::Utils::Hash.new('settings' => { a: '1' }))

          hash.each_value do |v|
            v.must_be(:frozen?)
          end
        end
      end
    end

    private

    def freeze(object)
      Hanami::Utils::Freezable.freeze(object)
      object
    end

    def assert_frozen(object)
      freeze(object)
      object.must_be(:frozen?)
    end

    def assert_unfrozen(object)
      freeze(object)
      object.wont_be(:frozen?)
    end
  end
end
