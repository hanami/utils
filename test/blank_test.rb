require 'test_helper'
require 'hanami/utils/kernel'
require 'hanami/utils/string'
require 'hanami/utils/hash'
require 'hanami/utils/blank'

describe Hanami::Utils::Blank do
  describe '.blank?' do
    [nil, false, '', '   ', "  \n\t  \r ", '　', "\u00a0", [], {},
     Hanami::Utils::Kernel.Boolean(0), Hanami::Utils::String.new(''),
     Hanami::Utils::Hash.new({})].each do |v|
       it 'returns true' do
         Hanami::Utils::Blank.blank?(v).must_equal true
       end
     end

     [Object.new, true, 0, 1, 'a', [nil], {nil => 0},
      Hanami::Utils::Kernel.Symbol(:hello), Hanami::Utils::String.new('foo'),
      Hanami::Utils::Hash.new({foo: :bar})].each do |v|
        it 'returns false' do
          Hanami::Utils::Blank.blank?(v).must_equal false
        end
      end
  end
end
