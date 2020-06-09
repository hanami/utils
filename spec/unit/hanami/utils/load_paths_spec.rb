# frozen_string_literal: true

require "hanami/utils/load_paths"

Hanami::Utils::LoadPaths.class_eval do
  def empty?
    @paths.empty?
  end

  def include?(object)
    @paths.include?(object)
  end
end

RSpec.describe Hanami::Utils::LoadPaths do
  describe "#initialize" do
    it "can be initialized with zero paths" do
      paths = Hanami::Utils::LoadPaths.new
      expect(paths).to be_empty
    end

    it "can be initialized with one path" do
      paths = Hanami::Utils::LoadPaths.new ".."
      expect(paths).to include("..")
    end

    it "can be initialized with more paths" do
      paths = Hanami::Utils::LoadPaths.new "..", "../.."

      expect(paths).to include("..")
      expect(paths).to include("../..")
    end
  end

  describe "#each" do
    it "coerces the given paths to pathnames and yields a block" do
      paths = Hanami::Utils::LoadPaths.new "..", "../.."

      paths.each do |path|
        expect(path).to be_kind_of Pathname
      end
    end

    it "remove duplicates" do
      paths = Hanami::Utils::LoadPaths.new "..", ".."
      expect(paths.each(&proc {}).size).to eq 1
    end

    it "raises an error if a path is unknown" do
      paths = Hanami::Utils::LoadPaths.new "unknown/path"

      expect { paths.each {} }.to raise_error(Errno::ENOENT)
    end
  end

  describe "#push" do
    it "adds the given path" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths.push ".."

      expect(paths).to include "."
      expect(paths).to include ".."
    end

    it "adds the given paths" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths.push "..", "../.."

      expect(paths).to include "."
      expect(paths).to include ".."
      expect(paths).to include "../.."
    end

    it "removes duplicates" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths.push ".", "."
      expect(paths.each(&proc {}).size).to eq 1
    end

    it "removes nil" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths.push nil
      expect(paths.each(&proc {}).size).to eq 1
    end

    it "returns self so multiple operations can be performed" do
      paths = Hanami::Utils::LoadPaths.new

      returning = paths.push(".")
      expect(returning).to equal(paths)

      paths.push("..").push("../..")

      expect(paths).to include "."
      expect(paths).to include ".."
      expect(paths).to include "../.."
    end
  end

  describe "#<< (alias of #push)" do
    it "adds the given path" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths << ".."

      expect(paths).to include "."
      expect(paths).to include ".."
    end

    it "adds the given paths" do
      paths = Hanami::Utils::LoadPaths.new "."
      paths << ["..", "../.."]

      expect(paths == [".", "..", "../.."]).to be_truthy
    end

    it "returns self so multiple operations can be performed" do
      paths = Hanami::Utils::LoadPaths.new

      returning = paths << "."
      expect(returning).to equal(paths)

      paths << ".." << "../.."

      expect(paths).to include "."
      expect(paths).to include ".."
      expect(paths).to include "../.."
    end
  end

  describe "#dup" do
    it "returns a copy of self" do
      paths  = Hanami::Utils::LoadPaths.new "."
      paths2 = paths.dup

      paths  << ".."
      paths2 << "../.."

      expect(paths).to include "."
      expect(paths).to include ".."
      expect(paths).not_to include "../.."

      expect(paths).to include "."
      expect(paths2).to include "../.."
      expect(paths2).not_to include ".."
    end
  end

  describe "#clone" do
    it "returns a copy of self" do
      paths  = Hanami::Utils::LoadPaths.new "."
      paths2 = paths.clone

      paths  << ".."
      paths2 << "../.."

      expect(paths).to include "."
      expect(paths).to include ".."
      expect(paths).not_to include "../.."

      expect(paths).to include "."
      expect(paths2).to include "../.."
      expect(paths2).not_to include ".."
    end
  end

  describe "#freeze" do
    it "freezes the object" do
      paths = Hanami::Utils::LoadPaths.new
      paths.freeze

      expect(paths).to be_frozen
    end

    it "doesn't allow to push paths" do
      paths = Hanami::Utils::LoadPaths.new
      paths.freeze

      expect { paths.push "." }.to raise_error(RuntimeError)
    end
  end

  describe "#==" do
    it "checks equality with LoadPaths" do
      paths = Hanami::Utils::LoadPaths.new(".", ".")
      other = Hanami::Utils::LoadPaths.new(".")

      expect(paths == other).to be_truthy
    end

    it "it returns false if the paths aren't equal" do
      paths = Hanami::Utils::LoadPaths.new(".", "..")
      other = Hanami::Utils::LoadPaths.new(".")

      expect(paths == other).to be_falsey
    end

    it "checks equality with Array" do
      paths = Hanami::Utils::LoadPaths.new(".", ".")
      other = ["."]

      expect(paths == other).to be_truthy
    end

    it "it returns false if given array isn't equal" do
      paths = Hanami::Utils::LoadPaths.new(".", "..")
      other = ["."]

      expect(paths == other).to be_falsey
    end

    it "it returns false the type isn't matchable" do
      paths = Hanami::Utils::LoadPaths.new(".", "..")
      other = nil

      expect(paths == other).to be_falsey
    end
  end
end
