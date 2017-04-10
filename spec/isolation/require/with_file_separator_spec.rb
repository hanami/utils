require_relative '../../support/isolation_spec_helper'

RSpec.describe 'Hanami::Utils.require!' do
  describe 'with file separator' do
    it 'applies current operating system file separator' do
      # Invert the file separator for the current operating system:
      #
      #   * on *NIX systems, instead of having /, we get \
      #   * on Windows systems, instead of having \, we get /
      separator = File::SEPARATOR == '/' ? '\\' : '/'
      directory = %w(spec support fixtures file_list).join(separator)
      Hanami::Utils.require!(directory)

      expect(defined?(A)).to  be_truthy, 'expected A to be defined'
      expect(defined?(Aa)).to be_truthy, 'expected Aa to be defined'
      expect(defined?(Ab)).to be_truthy, 'expected Ab to be defined'
      expect(defined?(C)).to  be_truthy, 'expected C to be defined'
    end
  end
end

RSpec::Support::Runner.run
