RSpec.describe Hanami::Utils do
  describe '.jruby?' do
    it 'introspects the current platform' do
      if RUBY_PLATFORM == 'java'
        expect(Hanami::Utils.jruby?).to eq(true)
      else
        expect(Hanami::Utils.jruby?).to eq(false)
      end
    end
  end

  describe '.rubinius?' do
    it 'introspects the current platform' do
      if RUBY_ENGINE == 'rbx'
        expect(Hanami::Utils.rubinius?).to eq(true)
      else
        expect(Hanami::Utils.rubinius?).to eq(false)
      end
    end
  end
end
