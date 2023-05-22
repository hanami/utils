require "hanami/utils/kernel"
require "hanami/utils/blank"

RSpec.describe Hanami::Utils::Blank do
  describe ".blank?" do
    [nil, false, "", "   ", "  \n\t  \r ", "　", "\u00a0", [], {}, Set.new,
     Hanami::Utils::Kernel.Boolean(0)].each do |v|
       it "returns true", silence_deprecations: true do
         expect(Hanami::Utils::Blank.blank?(v)).to eq(true)
       end
     end

    [Object.new, true, 0, 1, "a", :book, DateTime.now, Time.now, Date.new, [nil], {nil => 0}, Set.new([1]),
     Hanami::Utils::Kernel.Symbol(:hello)].each do |v|
       it "returns false", silence_deprecations: true do
         expect(Hanami::Utils::Blank.blank?(v)).to eq(false)
       end
     end
  end

  describe ".filled?" do
    [nil, false, "", "   ", "  \n\t  \r ", "　", "\u00a0", [], {}, Set.new,
     Hanami::Utils::Kernel.Boolean(0)].each do |v|
       it "returns false", silence_deprecations: true do
         expect(Hanami::Utils::Blank.filled?(v)).to eq(false)
       end
     end

    [Object.new, true, 0, 1, "a", :book, DateTime.now, Time.now, Date.new, [nil], {nil => 0}, Set.new([1]),
     Hanami::Utils::Kernel.Symbol(:hello)].each do |v|
       it "returns true", silence_deprecations: true do
         expect(Hanami::Utils::Blank.filled?(v)).to eq(true)
       end
     end
  end
end
