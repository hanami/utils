require 'test_helper'
require 'hanami/utils/file_list'

describe Hanami::Utils::FileList do
  describe '.[]' do
    it 'returns consistent file list across operating systems' do
      list = Hanami::Utils::FileList['test/fixtures/file_list/*.rb']
      list.must_equal [
        'test/fixtures/file_list/a.rb',
        'test/fixtures/file_list/aa.rb',
        'test/fixtures/file_list/ab.rb'
      ]
    end
  end
end
