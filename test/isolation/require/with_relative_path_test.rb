require 'test_helper'
require 'hanami/utils'

describe 'Hanami::Utils.require!' do
  describe 'with relative path' do
    it 'requires ordered set of files' do
      directory = Pathname.new('test').join('fixtures', 'file_list')
      Hanami::Utils.require!(directory)

      assert defined?(A),  'expected A to be defined'
      assert defined?(Aa), 'expected Aa to be defined'
      assert defined?(Ab), 'expected Ab to be defined'
      assert defined?(C),  'expected C to be defined'
    end
  end
end
