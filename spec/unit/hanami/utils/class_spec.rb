# frozen_string_literal: true

require "hanami/utils/class"
require "hanami/utils/io"

RSpec.describe Hanami::Utils::Class do
  before do
    Hanami::Utils::IO.silence_warnings do
      class Bar
        def level
          "top"
        end
      end

      class Foo
        class Bar
          def level
            "nested"
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

  describe ".load!" do
    it "loads the class from the given static string" do
      expect(Hanami::Utils::Class.load!("App::Layer::Step")).to eq(App::Layer::Step)
    end

    it "loads the class from the given static string and namespace" do
      expect(Hanami::Utils::Class.load!("Step", App::Layer)).to eq(App::Layer::Step)
    end

    it "loads the class from the given class name" do
      expect(Hanami::Utils::Class.load!(App::Layer::Step)).to eq(App::Layer::Step)
    end

    it "raises an error in case of missing class" do
      expect { Hanami::Utils::Class.load!("Missing") }.to raise_error(NameError)
    end
  end

  describe ".load" do
    it "loads the class from the given static string" do
      expect(Hanami::Utils::Class.load("App::Layer::Step")).to eq(App::Layer::Step)
    end

    it "loads the class from the given static string and namespace" do
      expect(Hanami::Utils::Class.load("Step", App::Layer)).to eq(App::Layer::Step)
    end

    it "loads the class from the given class name" do
      expect(Hanami::Utils::Class.load(App::Layer::Step)).to eq(App::Layer::Step)
    end

    it "returns nil in case of missing class" do
      expect(Hanami::Utils::Class.load("Missing")).to eq(nil)
    end
  end

  describe ".load_from_pattern!" do
    it "loads the class within the given namespace" do
      klass = Hanami::Utils::Class.load_from_pattern!("(Hanami|Foo)::Bar")
      expect(klass.new.level).to eq "nested"
    end

    it "loads the class within the given namespace, when first namespace does not exist" do
      klass = Hanami::Utils::Class.load_from_pattern!("(NotExisting|Foo)::Bar")
      expect(klass.new.level).to eq "nested"
    end

    it "loads the class within the given namespace when first namespace in pattern is correct one" do
      klass = Hanami::Utils::Class.load_from_pattern!("(Foo|Hanami)::Bar")
      expect(klass.new.level).to eq "nested"
    end

    it "loads the class from the given static string" do
      expect(Hanami::Utils::Class.load_from_pattern!("App::Layer::Step")).to eq(App::Layer::Step)
    end

    it "raises error for missing constant" do
      expect { Hanami::Utils::Class.load_from_pattern!("MissingConstant") }
        .to raise_error(NameError, "uninitialized constant MissingConstant")
    end

    it "raises error for missing constant with multiple alternatives" do
      expect { Hanami::Utils::Class.load_from_pattern!("Missing(Constant|Class)") }
        .to raise_error(NameError, "uninitialized constant Missing(Constant|Class)")
    end

    it "raises error with full constant name" do
      expect { Hanami::Utils::Class.load_from_pattern!("Step", App) }
        .to raise_error(NameError, "uninitialized constant App::Step")
    end

    it "raises error with full constant name and multiple alternatives" do
      expect { Hanami::Utils::Class.load_from_pattern!("(Step|Point)", App) }
        .to raise_error(NameError, "uninitialized constant App::(Step|Point)")
    end

    it "loads the class from given string, by interpolating tokens" do
      expect(Hanami::Utils::Class.load_from_pattern!("App::Service(::Point|Point)")).to eq(App::Service::Point)
    end

    it "loads the class from given string, by interpolating string tokens and respecting their order" do
      expect(Hanami::Utils::Class.load_from_pattern!("App::Service(Point|::Point)")).to eq(App::ServicePoint)
    end

    it "loads the class from given string, by interpolating tokens and not stopping after first fail" do
      expect(Hanami::Utils::Class.load_from_pattern!("App::(Layer|Layer::)Step")).to eq(App::Layer::Step)
    end

    it "loads class from given string and namespace" do
      expect(Hanami::Utils::Class.load_from_pattern!("(Layer|Layer::)Step", App)).to eq(App::Layer::Step)
    end
  end
end
