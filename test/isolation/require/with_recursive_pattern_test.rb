require 'test_helper'
require 'hanami/utils'

describe 'Hanami::Utils.require!' do
  describe 'with file separator' do
    it 'requires ordered set of files' do
      directory = %w(test fixtures file_list ** *.rb).join(File::SEPARATOR)
      Hanami::Utils.require!(directory)

      assert defined?(A),  'expected A to be defined'
      assert defined?(Aa), 'expected Aa to be defined'
      assert defined?(Ab), 'expected Ab to be defined'
      assert defined?(C),  'expected C to be defined'
    end
  end
end
