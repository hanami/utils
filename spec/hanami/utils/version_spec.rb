RSpec.describe Hanami::Utils::VERSION do
  it 'exposes version' do
    expect(Hanami::Utils::VERSION).to eq('1.0.0.beta3')
  end
end
