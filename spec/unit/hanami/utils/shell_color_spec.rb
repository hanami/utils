require "hanami/utils/shell_color"

RSpec.describe Hanami::Utils::ShellColor do
  describe ".call" do
    it "returns a string wrapped with black's code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :black)
      expect(result).to eq("\e[30mSakura\e[0m")
    end

    it "returns a string wrapped with red's code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :red)
      expect(result).to eq("\e[31mSakura\e[0m")
    end

    it "returns a string wrapped with green's code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :green)
      expect(result).to eq("\e[32mSakura\e[0m")
    end

    it "returns a string wrapped with yellow's code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :yellow)
      expect(result).to eq("\e[33mSakura\e[0m")
    end

    it "returns a string wrapped with blue's code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :blue)
      expect(result).to eq("\e[34mSakura\e[0m")
    end

    it "returns a string wrapped with magenta's escape code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :magenta)
      expect(result).to eq("\e[35mSakura\e[0m")
    end

    it "returns a string wrapped with cyan's escape code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :cyan)
      expect(result).to eq("\e[36mSakura\e[0m")
    end

    it "returns a string wrapped with gray's color code" do
      result = Hanami::Utils::ShellColor.call("Sakura", color: :gray)
      expect(result).to eq("\e[37mSakura\e[0m")
    end

    it "raises error for unknown color" do
      expect do
        Hanami::Utils::ShellColor.call("Sakura", color: :foo)
      end.to raise_error(Hanami::Utils::ShellColor::UnknownColorCodeError, "unknown color code: `:foo'")
    end
  end
end
