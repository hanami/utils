require 'test_helper'
require 'hanami/utils/load_paths'

Hanami::Utils::LoadPaths.class_eval do
  def empty?
    @paths.empty?
  end

  def include?(object)
    @paths.include?(object)
  end
end

describe Hanami::Utils::LoadPaths do
  describe '#initialize' do
    it 'can be initialized with zero paths' do
      paths = Hanami::Utils::LoadPaths.new
      paths.must_be_empty
    end

    it 'can be initialized with one path' do
      paths = Hanami::Utils::LoadPaths.new '..'
      paths.must_include '..'
    end

    it 'can be initialized with more paths' do
      paths = Hanami::Utils::LoadPaths.new '..', '../..'
      paths.must_include '..'
      paths.must_include '../..'
    end
  end

  describe '#each' do
    it 'coerces the given paths to pathnames and yields a block' do
      paths = Hanami::Utils::LoadPaths.new '..', '../..'

      paths.each do |path|
        path.must_be_kind_of Pathname
      end
    end

    it 'remove duplicates' do
      paths = Hanami::Utils::LoadPaths.new '..', '..'
      paths.each(&proc {}).size.must_equal 1
    end

    it 'raises an error if a path is unknown' do
      paths = Hanami::Utils::LoadPaths.new 'unknown/path'

      lambda do
        paths.each {}
      end.must_raise Errno::ENOENT
    end
  end

  describe '#push' do
    it 'adds the given path' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths.push '..'

      paths.must_include '.'
      paths.must_include '..'
    end

    it 'adds the given paths' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths.push '..', '../..'

      paths.must_include '.'
      paths.must_include '..'
      paths.must_include '../..'
    end

    it 'removes duplicates' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths.push '.', '.'
      paths.each(&proc {}).size.must_equal 1
    end

    it 'removes nil' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths.push nil
      paths.each(&proc {}).size.must_equal 1
    end

    it 'returns self so multiple operations can be performed' do
      paths = Hanami::Utils::LoadPaths.new

      returning = paths.push('.')
      returning.must_be_same_as(paths)

      paths.push('..').push('../..')

      paths.must_include '.'
      paths.must_include '..'
      paths.must_include '../..'
    end
  end

  describe '#<< (alias of #push)' do
    it 'adds the given path' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths << '..'

      paths.must_include '.'
      paths.must_include '..'
    end

    it 'adds the given paths' do
      paths = Hanami::Utils::LoadPaths.new '.'
      paths << ['..', '../..']

      assert paths == ['.', '..', '../..']
    end

    it 'returns self so multiple operations can be performed' do
      paths = Hanami::Utils::LoadPaths.new

      returning = paths << '.'
      returning.must_be_same_as(paths)

      paths << '..' << '../..'

      paths.must_include '.'
      paths.must_include '..'
      paths.must_include '../..'
    end
  end

  describe '#dup' do
    it 'returns a copy of self' do
      paths  = Hanami::Utils::LoadPaths.new '.'
      paths2 = paths.dup

      paths  << '..'
      paths2 << '../..'

      paths.must_include '.'
      paths.must_include '..'
      paths.wont_include '../..'

      paths.must_include  '.'
      paths2.must_include '../..'
      paths2.wont_include '..'
    end
  end

  describe '#clone' do
    it 'returns a copy of self' do
      paths  = Hanami::Utils::LoadPaths.new '.'
      paths2 = paths.clone

      paths  << '..'
      paths2 << '../..'

      paths.must_include '.'
      paths.must_include '..'
      paths.wont_include '../..'

      paths.must_include  '.'
      paths2.must_include '../..'
      paths2.wont_include '..'
    end
  end

  describe '#freeze' do
    it 'freezes the object' do
      paths = Hanami::Utils::LoadPaths.new
      paths.freeze

      paths.must_be :frozen?
    end

    it "doesn't allow to push paths" do
      paths = Hanami::Utils::LoadPaths.new
      paths.freeze

      -> { paths.push '.' }.must_raise RuntimeError
    end
  end

  describe '#==' do
    it 'checks equality with LoadPaths' do
      paths = Hanami::Utils::LoadPaths.new('.', '.')
      other = Hanami::Utils::LoadPaths.new('.')

      other.must_equal paths
    end

    it "it returns false if the paths aren't equal" do
      paths = Hanami::Utils::LoadPaths.new('.', '..')
      other = Hanami::Utils::LoadPaths.new('.')

      other.wont_equal paths
    end

    it 'checks equality with Array' do
      paths = Hanami::Utils::LoadPaths.new('.', '.')
      other = ['.']

      other.must_equal paths
    end

    it "it returns false if given array isn't equal" do
      paths = Hanami::Utils::LoadPaths.new('.', '..')
      other = ['.']

      other.wont_equal paths
    end

    it "it returns false the type isn't matchable" do
      paths = Hanami::Utils::LoadPaths.new('.', '..')
      other = nil

      other.wont_equal paths
    end
  end
end
