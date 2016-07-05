require 'test_helper'
require 'hanami/logger'
require 'rbconfig'

describe Hanami::Logger do

  before do
    #clear defined class
    Object.send(:remove_const, :TestLogger) if Object.constants.include?(:TestLogger)
  end

  it 'like std logger, sets log level to info by default' do
    class TestLogger < Hanami::Logger; end
    TestLogger.new.info?.must_equal true
  end

  describe '#initialize' do
    it 'uses STDOUT by default' do
      output =
        stub_stdout_constant do
          class TestLogger < Hanami::Logger; end
          logger = TestLogger.new
          logger.info('foo')
        end

      output.must_match(/foo/)
    end

    describe 'custom level option' do
      it 'takes a integer' do
        logger = Hanami::Logger.new(level: 3)
        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a integer more than 5' do
        logger = Hanami::Logger.new(level: 99)
        logger.level.must_equal Hanami::Logger::DEBUG
      end

      it 'takes a symbol' do
        logger = Hanami::Logger.new(level: :error)
        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a string' do
        logger = Hanami::Logger.new(level: 'error')
        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a string with strange value' do
        logger = Hanami::Logger.new(level: 'strange')
        logger.level.must_equal Hanami::Logger::DEBUG
      end

      it 'takes a uppercased string' do
        logger = Hanami::Logger.new(level: 'ERROR')
        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a constant' do
        logger = Hanami::Logger.new(level: Hanami::Logger::ERROR)
        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'contains debug level by default' do
        logger = Hanami::Logger.new
        logger.level.must_equal ::Logger::DEBUG
      end
    end

    describe 'custom stream' do
      describe 'file system' do
        before do
          Pathname.new(stream).dirname.mkpath
        end

        Hash[
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log').to_s => "absolute path (string)",
          Pathname.new('tmp').join('logfile.log').to_s          => "relative path (string)",
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log')      => "absolute path (pathname)",
          Pathname.new('tmp').join('logfile.log')               => "relative path (pathname)",
        ].each do |dev, desc|

          describe "when #{ desc }" do
            let(:stream) { dev }

            after do
              File.delete(stream)
            end

            describe 'and it does not exist' do
              before do
                File.delete(stream) if File.exist?(stream)
              end

              it 'writes to file' do
                logger = Hanami::Logger.new(stream: stream)
                logger.info('newline')

                contents = File.read(stream)
                contents.must_match(/newline/)
              end
            end

            describe 'and it already exists' do
              before do
                File.open(stream, File::WRONLY|File::TRUNC|File::CREAT, permissions) {|f| f.write('existing') }
              end

              let(:permissions) { 0664 }

              it 'appends to file' do
                logger = Hanami::Logger.new(stream: stream)
                logger.info('appended')

                contents = File.read(stream)
                contents.must_match(/existing/)
                contents.must_match(/appended/)
              end

              it 'does not change permissions' do
                logger = Hanami::Logger.new(stream: stream)
                logger.info('appended')
              end
            end
          end

        end # end loop

        describe 'when file' do
          let(:stream)      { Pathname.new('tmp').join('logfile.log') }
          let(:log_file)    { File.new(stream, 'w+', permissions) }
          let(:permissions) { 0644 }

          before(:each) do
            log_file.write('hello')
          end

          describe 'and already written' do
            it 'appends to file' do
              logger = Hanami::Logger.new(stream: log_file)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              contents.must_match(/hello/)
              contents.must_match(/world/)
            end

            it 'does not change permissions' do
              logger = Hanami::Logger.new(stream: log_file)
              logger.info('appended')
              logger.close

              stat = File.stat(log_file)
              stat.mode.to_s(8).must_match('100644')
            end
          end
        end # end File

        describe 'when IO' do
          let(:stream) { Pathname.new('tmp').join('logfile.log').to_s }

          it 'appends' do
            fd = IO.sysopen(stream, 'w')
            io = IO.new(fd, 'w')

            logger = Hanami::Logger.new(stream: io)
            logger.info('in file')
            logger.close

            contents = File.read(stream)
            contents.must_match(/in file/)
          end
        end # end IO

      end # end FileSystem

      describe 'when StringIO' do
        let(:stream) { StringIO.new }

        it 'appends' do
          logger = Hanami::Logger.new(stream: stream)
          logger.info('in file')

          stream.rewind
          stream.read.must_match(/in file/)
        end
      end # end StringIO

    end # end #initialize


    describe "#close" do
      it 'does not close STDOUT output for other code' do
        logger = Hanami::Logger.new(stream: STDOUT)
        logger.close

        assert_output('in STDOUT') { print 'in STDOUT' }
      end

      it 'does not close $stdout output for other code' do
        logger = Hanami::Logger.new(stream: $stdout)
        logger.close

        assert_output('in $stdout') { print 'in $stdout' }
      end
    end

    describe '#level=' do
      it 'takes a integer' do
        logger = Hanami::Logger.new
        logger.level = 3

        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a integer more than 5' do
        logger = Hanami::Logger.new
        logger.level = 99

        logger.level.must_equal Hanami::Logger::DEBUG
      end

      it 'takes a symbol' do
        logger = Hanami::Logger.new
        logger.level = :error

        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a string' do
        logger = Hanami::Logger.new
        logger.level = 'error'

        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a string with strange value' do
        logger = Hanami::Logger.new
        logger.level = 'strange'

        logger.level.must_equal Hanami::Logger::DEBUG
      end

      it 'takes a uppercased string' do
        logger = Hanami::Logger.new
        logger.level = 'ERROR'

        logger.level.must_equal Hanami::Logger::ERROR
      end

      it 'takes a constant' do
        logger = Hanami::Logger.new
        logger.level = Hanami::Logger::ERROR

        logger.level.must_equal Hanami::Logger::ERROR
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

    describe 'with nil formatter' do
      it 'falls back to Formatter' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: nil).info('foo')
            end
          output.must_equal "app=Hanami severity=INFO time=1988-09-01 00:00:00 UTC message=foo\n"
        end
      end
    end

    describe 'with JSON formatter' do
      it 'when passed as a symbol, it has JSON format for string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: :json).info('foo')
            end
          output.must_equal "{\"app\":\"Hanami\",\"severity\":\"INFO\",\"time\":\"1988-09-01 00:00:00 UTC\",\"message\":\"foo\"}"
        end
      end

      it 'has JSON format for string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info('foo')
            end
          output.must_equal "{\"app\":\"Hanami\",\"severity\":\"INFO\",\"time\":\"1988-09-01 00:00:00 UTC\",\"message\":\"foo\"}"
        end
      end

      it 'has JSON format for error messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).error(Exception.new('foo'))
            end
          output.must_equal "{\"app\":\"Hanami\",\"severity\":\"ERROR\",\"time\":\"1988-09-01 00:00:00 UTC\",\"message\":\"foo\",\"backtrace\":[],\"error\":\"Exception\"}"
        end
      end

      it 'has JSON format for hash messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info(foo: :bar)
            end
          output.must_equal "{\"app\":\"Hanami\",\"severity\":\"INFO\",\"time\":\"1988-09-01 00:00:00 UTC\",\"foo\":\"bar\"}"
        end
      end

      it 'has JSON format for not string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info(['foo'])
            end
          output.must_equal "{\"app\":\"Hanami\",\"severity\":\"INFO\",\"time\":\"1988-09-01 00:00:00 UTC\",\"message\":[\"foo\"]}"
        end
      end
    end

    describe 'with default formatter' do
      it 'when passed as a symbol, it has key=value format for string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new(formatter: :default).info('foo')
            end
          output.must_equal "app=Hanami severity=INFO time=1988-09-01 00:00:00 UTC message=foo\n"
        end
      end

      it 'has key=value format for string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new.info('foo')
            end
          output.must_equal "app=Hanami severity=INFO time=1988-09-01 00:00:00 UTC message=foo\n"
        end
      end

      it 'has key=value format for error messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new.error(Exception.new('foo'))
            end
          output.must_equal "app=Hanami severity=ERROR time=1988-09-01 00:00:00 UTC message=foo backtrace=[] error=Exception\n"
        end
      end

      it 'has key=value format for hash messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new.info(foo: :bar)
            end
          output.must_equal "app=Hanami severity=INFO time=1988-09-01 00:00:00 UTC foo=bar\n"
        end
      end

      it 'has key=value format for not string messages' do
        stub_time_now do
          output =
            stub_stdout_constant do
              class TestLogger < Hanami::Logger;end
              TestLogger.new.info(['foo'])
            end
          output.must_equal "app=Hanami severity=INFO time=1988-09-01 00:00:00 UTC message=[\"foo\"]\n"
        end
      end
    end
  end
end
