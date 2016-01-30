require 'test_helper'
require 'hanami/logger'

describe Hanami::Logger do

  before do
    #clear defined class
    Object.send(:remove_const, :TestLogger) if Object.constants.include?(:TestLogger)
  end

  it 'like std logger, sets log level to info by default' do
    class TestLogger < Hanami::Logger; end
    TestLogger.new.info?.must_equal true
  end

  it 'use STDOUT' do
    output =
      stub_stdout_constant do
        class TestLogger < Hanami::Logger; end
        logger = TestLogger.new
        logger.info('foo')
      end

    output.must_match(/foo/)
  end

  it 'use file name' do
    output =
      stub_stdout_constant do
        class TestLogger < Hanami::Logger; end
        logger = TestLogger.new
        logger.info('foo')
      end

    output.must_match(/foo/)
  end

  describe 'when IO is file' do
    before do
      FileUtils.touch(log_path) unless File.exist?(log_path)
    end

    after do
      File.delete(log_path)
    end

    let(:log_path) { "#{Dir.pwd}/tmp/logfile.log" }
    let(:relative_log_path) { "tmp/logfile.log" }

    it 'accepts absolute file name' do
      logger = Hanami::Logger.new(log_device: log_path)
      logger.info('in file')
      logger.close

      contents = File.read(log_path)
      contents.must_match(/in file/)
    end

    it 'accepts relative file name' do
      logger = Hanami::Logger.new(log_device: relative_log_path)
      logger.info('in file')
      logger.close

      contents = File.read(log_path)
      contents.must_match(/in file/)
    end

    it 'accepts open file' do
      log_file = File.new(log_path, 'w+')
      logger = Hanami::Logger.new(log_device: log_file)
      logger.info('in file')
      logger.close

      contents = File.read(log_path)
      contents.must_match(/in file/)
    end

    it 'creates log file with right permission' do
      logger = Hanami::Logger.new(log_device: log_path)
      logger.info('in file')
      logger.close

      file_permission = sprintf("%o", File.world_readable?(log_path))
      file_permission.must_equal('644')
    end
  end

  it 'has application_name when log' do
    output =
      stub_stdout_constant do
        module App; class TestLogger < Hanami::Logger; end; end
        logger = App::TestLogger.new
        logger.info('foo')
      end

    output.must_match(/App/)
  end

  it 'has default app tag when not in any namespace' do
    class TestLogger < Hanami::Logger; end
    TestLogger.new.application_name.must_equal 'Hanami'
  end

  it 'infers apptag from namespace' do
    module App2
      class TestLogger < Hanami::Logger;end
      class Bar
        def hoge
          TestLogger.new.send(:application_name).must_equal 'App2'
        end
      end
    end
    App2::Bar.new.hoge
  end

  it 'uses custom application_name from override class' do
    class TestLogger < Hanami::Logger; def application_name; 'bar'; end; end

    output =
      stub_stdout_constant do
        TestLogger.new.info('')
      end

    output.must_match(/bar/)
  end

  it 'has format "#{Severity}, [%Y-%m-%dT%H:%M:%S.%6N #{Pid}] #{Severity} -- [#{application_name}] : #{message}\n"' do
    stub_time_now do
      output =
        stub_stdout_constant do
          class TestLogger < Hanami::Logger;end
          TestLogger.new.info('foo')
        end
      output.must_equal "I, [1988-09-01T00:00:00.000000 ##{Process.pid}]  INFO -- [Hanami] : foo\n"
    end
  end
end
