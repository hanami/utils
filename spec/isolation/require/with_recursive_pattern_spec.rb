require_relative '../../support/isolation_spec_helper'

RSpec.describe 'Hanami::Utils.require!' do
  describe 'with file separator' do
    it 'requires ordered set of files' do
      directory = %w(spec support fixtures file_list ** *.rb).join(File::SEPARATOR)
      Hanami::Utils.require!(directory)

      expect(defined?(A)).to  be_truthy, 'expected A to be defined'
      expect(defined?(Aa)).to be_truthy, 'expected Aa to be defined'
      expect(defined?(Ab)).to be_truthy, 'expected Ab to be defined'
      expect(defined?(C)).to  be_truthy, 'expected C to be defined'
    end
  end
end

RSpec::Support::Runner.run
