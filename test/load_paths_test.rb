require 'test_helper'
require 'lotus/utils/load_paths'

Lotus::Utils::LoadPaths.class_eval do
  def empty?
    @paths.empty?
  end

  def include?(object)
    @paths.include?(object)
  end
end

describe Lotus::Utils::LoadPaths do
  describe '#initialize' do
    it 'can be initialized with zero paths' do
      paths = Lotus::Utils::LoadPaths.new
      paths.must_be_empty
    end

    it 'can be initialized with one path' do
      paths = Lotus::Utils::LoadPaths.new '..'
      paths.must_include '..'
    end

    it 'can be initialized with more paths' do
      paths = Lotus::Utils::LoadPaths.new '..', '../..'
      paths.must_include '..'
      paths.must_include '../..'
    end
  end

  describe '#each' do
    it 'coerces the given paths to pathnames and yields a block' do
      paths = Lotus::Utils::LoadPaths.new '..', '../..'

      paths.each do |path|
        path.must_be_kind_of Pathname
      end
    end

    it 'remove duplicates' do
      paths   = Lotus::Utils::LoadPaths.new '..', '..'
      paths.each(&Proc.new{}).size.must_equal 1
    end

    it 'raises an error if a path is unknown' do
      paths = Lotus::Utils::LoadPaths.new 'unknown/path'

      -> {
        paths.each { }
      }.must_raise Errno::ENOENT
    end
  end
end
