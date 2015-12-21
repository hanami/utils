require 'test_helper'
require 'lotus/utils/class'

describe Lotus::Utils::Class do
  before do
    module App
      module Layer
        class Step
        end
      end

      module Service
        class Point
        end
      end

      class ServicePoint
      end
    end
  end

  describe '.load!' do
    it 'loads the class from the given static string' do
      Lotus::Utils::Class.load!('App::Layer::Step').must_equal(App::Layer::Step)
    end

    it 'loads the class from the given static string and namespace' do
      Lotus::Utils::Class.load!('Step', App::Layer).must_equal(App::Layer::Step)
    end

    it 'loads the class from the given class name' do
      Lotus::Utils::Class.load!(App::Layer::Step).must_equal(App::Layer::Step)
    end

    it 'raises an error in case of missing class' do
      -> { Lotus::Utils::Class.load!('Missing') }.must_raise(NameError)
    end
  end

  describe '.load_from_pattern!' do
    it 'loads the class from the given static string' do
      Lotus::Utils::Class.load_from_pattern!('App::Layer::Step').must_equal(App::Layer::Step)
    end

    it 'raises error for missing constant' do
      error = -> { Lotus::Utils::Class.load_from_pattern!('MissingConstant') }.must_raise(NameError)
      error.message.must_equal "uninitialized constant MissingConstant"
    end

    it 'raises error for missing constant with multiple alternatives' do
      error = -> { Lotus::Utils::Class.load_from_pattern!('Missing(Constant|Class)') }.must_raise(NameError)
      error.message.must_equal "uninitialized constant Missing(Constant|Class)"
    end

    it 'raises error with full constant name' do
      error = -> { Lotus::Utils::Class.load_from_pattern!('Step', App) }.must_raise(NameError)
      error.message.must_equal "uninitialized constant App::Step"
    end

    it 'raises error with full constant name and multiple alternatives' do
      error = -> { Lotus::Utils::Class.load_from_pattern!('(Step|Point)', App) }.must_raise(NameError)
      error.message.must_equal "uninitialized constant App::(Step|Point)"
    end

    it 'loads the class from given string, by interpolating tokens' do
      Lotus::Utils::Class.load_from_pattern!('App::Service(::Point|Point)').must_equal(App::Service::Point)
    end

    it 'loads the class from given string, by interpolating string tokens and respecting their order' do
      Lotus::Utils::Class.load_from_pattern!('App::Service(Point|::Point)').must_equal(App::ServicePoint)
    end

    it 'loads the class from given string, by interpolating tokens and not stopping after first fail' do
      Lotus::Utils::Class.load_from_pattern!('App::(Layer|Layer::)Step').must_equal(App::Layer::Step)
    end

    it 'loads class from given string and namespace' do
      Lotus::Utils::Class.load_from_pattern!('(Layer|Layer::)Step', App).must_equal(App::Layer::Step)
    end
  end
end
