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

  it 'always use STDOUT' do
    output =
      stub_stdout_constant do
        class TestLogger < Hanami::Logger; end
        logger = TestLogger.new
        logger.info('foo')
      end

    output.must_match(/foo/)
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
