require_relative '../../support/isolation_spec_helper'

RSpec.describe 'Hanami::Utils.require!' do
  describe 'with relative path' do
    it 'requires ordered set of files' do
      directory = Pathname.new('spec').join('support', 'fixtures', 'file_list')
      Hanami::Utils.require!(directory)

      expect(defined?(A)).to  be_truthy, 'expected A to be defined'
      expect(defined?(Aa)).to be_truthy, 'expected Aa to be defined'
      expect(defined?(Ab)).to be_truthy, 'expected Ab to be defined'
      expect(defined?(C)).to  be_truthy, 'expected C to be defined'
    end
  end
end

RSpec::Support::Runner.run
