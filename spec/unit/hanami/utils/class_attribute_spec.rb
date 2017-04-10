require 'hanami/utils/class_attribute'

RSpec.describe Hanami::Utils::ClassAttribute do
  before do
    class ClassAttributeTest
      include Hanami::Utils::ClassAttribute
      class_attribute :callbacks, :functions, :values
      self.callbacks = [:a]
      self.values    = [1]
    end

    class SubclassAttributeTest < ClassAttributeTest
      class_attribute :subattribute
      self.functions    = %i(x y)
      self.subattribute = 42
    end

    class SubSubclassAttributeTest < SubclassAttributeTest
    end

    class Vehicle
      include Hanami::Utils::ClassAttribute
      class_attribute :engines, :wheels

      self.engines = 0
      self.wheels  = 0
    end

    class Car < Vehicle
      self.engines = 1
      self.wheels  = 4
    end

    class Airplane < Vehicle
      self.engines = 4
      self.wheels  = 16
    end

    class SmallAirplane < Airplane
      self.engines = 2
      self.wheels  = 8
    end
  end

  after do
    %i(ClassAttributeTest
       SubclassAttributeTest
       SubSubclassAttributeTest
       Vehicle
       Car
       Airplane
       SmallAirplane).each do |const|
         Object.send :remove_const, const
       end
  end

  it 'sets the given value' do
    expect(ClassAttributeTest.callbacks).to eq([:a])
  end

  describe 'inheritance' do
    around do |example|
      @debug = $DEBUG
      $DEBUG = true

      example.run

      $DEBUG = @debug
    end

    it 'the value it is inherited by subclasses' do
      expect(SubclassAttributeTest.callbacks).to eq([:a])
    end

    it 'if the superclass value changes it does not affects subclasses' do
      ClassAttributeTest.functions = [:y]
      expect(SubclassAttributeTest.functions).to eq(%i(x y))
    end

    it 'if the subclass value changes it does not affects superclass' do
      SubclassAttributeTest.values = [3, 2]
      expect(ClassAttributeTest.values).to eq([1])
    end

    describe 'when the subclass is defined in a different namespace' do
      before do
        module Lts
          module Routing
            class Resource
              class Action
                include Hanami::Utils::ClassAttribute
                class_attribute :verb
              end

              class New < Action
                self.verb = :get
              end
            end

            class Resources < Resource
              class New < Resource::New
              end
            end
          end
        end
      end

      it 'refers to the superclass value' do
        expect(Lts::Routing::Resources::New.verb).to eq :get
      end
    end

    # it 'if the subclass value changes it affects subclasses' do
    #   values = [3,2]
    #   SubclassAttributeTest.values = values
    #    expect(SubclassAttributeTest.values).to eq(values)
    #    expect(SubSubclassAttributeTest.values).to eq(values)
    # end

    it 'if the subclass defines an attribute it should not be available for the superclass' do
      $DEBUG = @debug
      expect { ClassAttributeTest.subattribute }.to raise_error(NoMethodError)
    end

    it 'if the subclass defines an attribute it should be available for its subclasses' do
      expect(SubSubclassAttributeTest.subattribute).to eq 42
    end

    it 'preserves values within the inheritance chain' do
      expect(Vehicle.engines).to eq 0
      expect(Vehicle.wheels).to eq  0

      expect(Car.engines).to eq 1
      expect(Car.wheels).to eq  4

      expect(Airplane.engines).to eq 4
      expect(Airplane.wheels).to eq  16

      expect(SmallAirplane.engines).to eq 2
      expect(SmallAirplane.wheels).to eq  8
    end

    it "doesn't print warnings when it gets inherited" do
      expect { Class.new(Vehicle) }.not_to output.to_stdout
    end
  end
end
