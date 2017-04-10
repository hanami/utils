require 'hanami/utils/kernel'
require 'hanami/utils/string'
require 'hanami/utils/hash'
require 'hanami/utils/blank'

RSpec.describe Hanami::Utils::Blank do
  describe '.blank?' do
    [nil, false, '', '   ', "  \n\t  \r ", '　', "\u00a0", [], {}, Set.new,
     Hanami::Utils::Kernel.Boolean(0), Hanami::Utils::String.new(''),
     Hanami::Utils::Hash.new({})].each do |v|
       it 'returns true' do
         expect(Hanami::Utils::Blank.blank?(v)).to eq(true)
       end
     end

    [Object.new, true, 0, 1, 'a', :book, DateTime.now, Time.now, Date.new, [nil], { nil => 0 }, Set.new([1]),
     Hanami::Utils::Kernel.Symbol(:hello), Hanami::Utils::String.new('foo'),
     Hanami::Utils::Hash.new(foo: :bar)].each do |v|
       it 'returns false' do
         expect(Hanami::Utils::Blank.blank?(v)).to eq(false)
       end
     end
  end

  describe '.filled?' do
    [nil, false, '', '   ', "  \n\t  \r ", '　', "\u00a0", [], {}, Set.new,
     Hanami::Utils::Kernel.Boolean(0), Hanami::Utils::String.new(''),
     Hanami::Utils::Hash.new({})].each do |v|
       it 'returns false' do
         expect(Hanami::Utils::Blank.filled?(v)).to eq(false)
       end
     end

    [Object.new, true, 0, 1, 'a', :book, DateTime.now, Time.now, Date.new, [nil], { nil => 0 }, Set.new([1]),
     Hanami::Utils::Kernel.Symbol(:hello), Hanami::Utils::String.new('foo'),
     Hanami::Utils::Hash.new(foo: :bar)].each do |v|
       it 'returns true' do
         expect(Hanami::Utils::Blank.filled?(v)).to eq(true)
       end
     end
  end
end
