require 'test_helper'
require 'lotus/utils'
require 'lotus/utils/template'

describe Lotus::Utils::Template do
  describe '#initialize' do
    it 'accepts one argument' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb')
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal Encoding::UTF_8
    end

    it 'allows to specify encoding (as string)' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb', 'ISO-8859-1')
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal 'ISO-8859-1'
    end

    it 'allows to specify encoding (as constant)' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb', Encoding::ISO_8859_1)
      template.instance_variable_get(:@_template).__send__(:default_encoding).must_equal Encoding::ISO_8859_1
    end
  end

  describe '#file' do
    it 'returns file path' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb')
      template.file.must_equal "#{Dir.pwd}/test/fixtures/templates/hello_world.html.erb"
    end
  end

  describe '#format' do
    it 'returns html format' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb')
      template.format.must_equal :html
    end
  end

  describe '#render' do
    it 'renders template file' do
      template = Lotus::Utils::Template.new(__dir__ + '/fixtures/templates/hello_world.html.erb')
      template.render.must_equal "<h1>Hello, World!</h1>\n"
    end
  end
end
