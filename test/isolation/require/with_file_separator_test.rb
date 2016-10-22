require 'test_helper'
require 'hanami/utils'

describe 'Hanami::Utils.require!' do
  describe 'with file separator' do
    it 'applies current operating system file separator' do
      # Invert the file separator for the current operating system:
      #
      #   * on *NIX systems, instead of having /, we get \
      #   * on Windows systems, instead of having \, we get /
      separator = File::SEPARATOR == '/' ? '\\' : '/'
      directory = %w(test fixtures file_list).join(separator)
      Hanami::Utils.require!(directory)

      assert defined?(A),  'expected A to be defined'
      assert defined?(Aa), 'expected Aa to be defined'
      assert defined?(Ab), 'expected Ab to be defined'
      assert defined?(C),  'expected C to be defined'
    end
  end
end
