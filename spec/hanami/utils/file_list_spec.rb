require 'hanami/utils/file_list'

RSpec.describe Hanami::Utils::FileList do
  describe '.[]' do
    it 'returns consistent file list across operating systems' do
      list = Hanami::Utils::FileList['test/fixtures/file_list/*.rb']
      expect(list).to eq [
        'test/fixtures/file_list/a.rb',
        'test/fixtures/file_list/aa.rb',
        'test/fixtures/file_list/ab.rb'
      ]
    end
  end
end
