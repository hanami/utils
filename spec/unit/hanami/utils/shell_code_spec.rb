require 'hanami/utils/shell_code'

RSpec.describe Hanami::Utils::ShellCode do
  describe '.colorize' do
    it "returns a string wrapped with black's code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :black)
      expect(result).to eq("\e[30mSakura\e[0m")
    end

    it "returns a string wrapped with red's code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :red)
      expect(result).to eq("\e[31mSakura\e[0m")
    end

    it "returns a string wrapped with green's code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :green)
      expect(result).to eq("\e[32mSakura\e[0m")
    end

    it "returns a string wrapped with yellow's code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :yellow)
      expect(result).to eq("\e[33mSakura\e[0m")
    end

    it "returns a string wrapped with blue's code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :blue)
      expect(result).to eq("\e[34mSakura\e[0m")
    end

    it "returns a string wrapped with magenta's escape code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :magenta)
      expect(result).to eq("\e[35mSakura\e[0m")
    end

    it "returns a string wrapped with cyan's escape code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :cyan)
      expect(result).to eq("\e[36mSakura\e[0m")
    end

    it "returns a string wrapped with gray's color code" do
      result = Hanami::Utils::ShellCode.colorize('Sakura', color: :gray)
      expect(result).to eq("\e[37mSakura\e[0m")
    end
  end

  # describe '#initialize' do
  #   it 'uses STDOUT by default' do
  #     output =
  #       with_captured_stdout do
  #         class TestLogger < Hanami::Logger; end
  #         logger = TestLogger.new
  #         logger.info('foo')
  #       end

  #     expect(output).to match(/foo/)
  #   end

  #   it 'has key=value format for error messages' do
  #     exception = nil
  #     output = with_captured_stdout do
  #       class TestLogger < Hanami::Logger; end
  #       begin
  #         raise StandardError.new('foo')
  #       rescue => e
  #         exception = e
  #       end
  #       TestLogger.new.error(exception)
  #     end
  #     expectation = "[hanami] [ERROR] [2017-01-15 16:00:23 +0100] \e[31mStandardError: foo\e[0m\n"
  #     exception.backtrace.each do |line|
  #       expectation << "\e[33mfrom #{line}\n\e[0m"
  #     end
  #     expect(output).to eq expectation
  #   end
  # end
end
