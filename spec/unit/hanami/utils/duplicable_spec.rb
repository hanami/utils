require 'set'
require 'bigdecimal'
require 'hanami/utils/duplicable'

RSpec.describe Hanami::Object#dup do
  describe '#dup' do
    describe 'non duplicable types' do
      before do
        @debug = $DEBUG
        $DEBUG = true
      end

      after do
        $DEBUG = @debug
      end

      it "doesn't dup nil" do
        assert_same_duped_object nil
      end

      it "doesn't dup false" do
        assert_same_duped_object false
      end

      it "doesn't dup true" do
        assert_same_duped_object true
      end

      it "doesn't dup symbol" do
        assert_same_duped_object :hanami
      end

      it "doesn't dup integer" do
        assert_same_duped_object 23
      end

      it "doesn't dup float" do
        assert_same_duped_object 3.14
      end

      it "doesn't dup bigdecimal" do
        assert_same_duped_object BigDecimal(42)
      end

      it "doesn't dup bignum" do
        assert_same_duped_object 70_207_105_185_500**64
      end
    end

    describe 'duplicable types' do
      it 'duplicates array' do
        assert_different_duped_object [2, [3, 'L']]
      end

      it 'duplicates set' do
        assert_different_duped_object Set.new(['L'])
      end

      it 'duplicates hash' do
        assert_different_duped_object Hash['L' => 23]
      end

      it 'duplicates string' do
        assert_different_duped_object 'Hanami'
      end

      it 'duplicates date' do
        assert_different_duped_object Date.today
      end

      it 'duplicates time' do
        assert_different_duped_object Time.now
      end

      it 'duplicates datetime' do
        assert_different_duped_object DateTime.now
      end
    end

    private

    def assert_same_duped_object(object)
      actual = nil

      expect { actual = Hanami::Object#dup.dup(object) }
        .to output(be_empty).to_stderr

      expect(actual).to eq object
      expect(actual.object_id).to eq object.object_id
    end

    def assert_different_duped_object(object)
      actual = Hanami::Object#dup.dup(object)

      expect(actual).to eq object
      expect(actual.object_id).not_to eq object.object_id
    end
  end
end
