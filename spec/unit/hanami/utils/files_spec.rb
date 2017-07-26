require "hanami/utils/files"
require "securerandom"

RSpec.describe Hanami::Utils::Files do
  let(:root) { Pathname.new(Dir.pwd).join("tmp", SecureRandom.uuid).tap(&:mkpath) }

  after do
    FileUtils.remove_entry_secure(root)
  end

  describe ".touch" do
    it "creates an empty file" do
      path = root.join("touch")
      described_class.touch(path)

      expect(path).to exist
      expect(path).to have_content("")
    end

    it "creates intermediate directories" do
      path = root.join("path", "to", "file", "touch")
      described_class.touch(path)

      expect(path).to exist
      expect(path).to have_content("")
    end

    it "leaves untouched existing file" do
      path = root.join("touch")
      path.open("wb+") { |p| p.write("foo") }
      described_class.touch(path)

      expect(path).to exist
      expect(path).to have_content("foo")
    end
  end

  describe ".write" do
    it "creates an file with given contents" do
      path = root.join("write")
      described_class.write(path, "Hello\nWorld")

      expect(path).to exist
      expect(path).to have_content("Hello\nWorld")
    end

    it "creates intermediate directories" do
      path = root.join("path", "to", "file", "write")
      described_class.write(path, ":)")

      expect(path).to exist
      expect(path).to have_content(":)")
    end

    it "overrides previous contentes" do
      path = root.join("write")
      described_class.write(path, "some words")
      described_class.write(path, "some other words")

      expect(path).to exist
      expect(path).to have_content("some other words")
    end

    it "is aliased as rewrite" do
      path = root.join("rewrite")
      described_class.rewrite(path, "rewrite me")

      expect(path).to exist
      expect(path).to have_content("rewrite me")
    end
  end

  describe ".cp" do
    let(:source) { root.join("..", "source") }

    before do
      source.delete if source.exist?
    end

    it "creates an file with given contents" do
      described_class.write(source, "the source")

      destination = root.join("cp")
      described_class.cp(source, destination)

      expect(destination).to exist
      expect(destination).to have_content("the source")
    end

    it "creates intermediate directories" do
      source = root.join("..", "source")
      described_class.write(source, "the source for intermediate directories")

      destination = root.join("cp", "destination")
      described_class.cp(source, destination)

      expect(destination).to exist
      expect(destination).to have_content("the source for intermediate directories")
    end

    it "overrides already existing file" do
      source = root.join("..", "source")
      described_class.write(source, "the source")

      destination = root.join("cp")
      described_class.write(destination, "the destination")
      described_class.cp(source, destination)

      expect(destination).to exist
      expect(destination).to have_content("the source")
    end
  end

  describe ".mkdir" do
    it "creates directory" do
      path = root.join("mkdir")
      described_class.mkdir(path)

      expect(path).to be_directory
    end

    it "creates intermediate directories" do
      path = root.join("path", "to", "mkdir")
      described_class.mkdir(path)

      expect(path).to be_directory
    end
  end

  describe ".mkdir_p" do
    it "creates directory" do
      directory = root.join("mkdir_p")
      path = directory.join("file.rb")
      described_class.mkdir_p(path)

      expect(directory).to be_directory
      expect(path).to_not  exist
    end

    it "creates intermediate directories" do
      directory = root.join("path", "to", "mkdir_p")
      path = directory.join("file.rb")
      described_class.mkdir_p(path)

      expect(directory).to be_directory
      expect(path).to_not  exist
    end
  end

  describe ".delete" do
    it "deletes path" do
      path = root.join("delete", "file")
      described_class.touch(path)
      described_class.delete(path)

      expect(path).to_not exist
    end

    it "raises error if path doesn't exist" do
      path = root.join("delete", "file")

      expect { described_class.delete(path) }.to raise_error do |exception|
        expect(exception).to be_kind_of(Errno::ENOENT)
        expect(exception.message).to match("No such file or directory")
      end

      expect(path).to_not exist
    end
  end

  describe ".delete_directory" do
    it "deletes directory" do
      path = root.join("delete", "directory")
      described_class.mkdir(path)
      described_class.delete_directory(path)

      expect(path).to_not exist
    end

    it "raises error if directory doesn't exist" do
      path = root.join("delete", "directory")

      expect { described_class.delete_directory(path) }.to raise_error do |exception|
        expect(exception).to be_kind_of(Errno::ENOENT)
        expect(exception.message).to match("No such file or directory")
      end

      expect(path).to_not exist
    end
  end
end
