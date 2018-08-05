require 'hanami/utils/class'
require 'hanami/utils/io'

RSpec.describe Hanami::Utils::Class do
  before do
    Hanami::Utils::IO.silence_warnings do
      class Bar
        def level
          'top'
        end
      end

      class Foo
        class Bar
          def level
            'nested'
          end
        end
      end

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
  end

  describe '.load!' do
    it 'loads the class from the given static string' do
      expect(Hanami::Utils::Class.load!('App::Layer::Step')).to eq(App::Layer::Step)
    end

    it 'loads the class from the given static string and namespace' do
      expect(Hanami::Utils::Class.load!('Step', App::Layer)).to eq(App::Layer::Step)
    end

    it 'loads the class from the given class name' do
      expect(Hanami::Utils::Class.load!(App::Layer::Step)).to eq(App::Layer::Step)
    end

    it 'raises an error in case of missing class' do
      expect { Hanami::Utils::Class.load!('Missing') }.to raise_error(NameError)
    end
  end

  describe '.load' do
    it 'loads the class from the given static string' do
      expect(Hanami::Utils::Class.load('App::Layer::Step')).to eq(App::Layer::Step)
    end

    it 'loads the class from the given static string and namespace' do
      expect(Hanami::Utils::Class.load('Step', App::Layer)).to eq(App::Layer::Step)
    end

    it 'loads the class from the given class name' do
      expect(Hanami::Utils::Class.load(App::Layer::Step)).to eq(App::Layer::Step)
    end

    it 'returns nil in case of missing class' do
      expect(Hanami::Utils::Class.load('Missing')).to eq(nil)
    end
  end
end
