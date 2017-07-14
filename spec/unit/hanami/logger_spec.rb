require 'hanami/logger'
require 'rbconfig'

RSpec.describe Hanami::Logger do
  before do
    # clear defined class
    Object.send(:remove_const, :TestLogger) if Object.constants.include?(:TestLogger)

    allow(Time).to receive(:now).and_return(Time.parse("2017-01-15 16:00:23 +0100"))
  end

  it 'like std logger, sets log level to info by default' do
    class TestLogger < Hanami::Logger; end
    expect(TestLogger.new.info?).to eq true
  end

  describe '#initialize' do
    it 'uses STDOUT by default' do
      output =
        with_captured_stdout do
          class TestLogger < Hanami::Logger; end
          logger = TestLogger.new
          logger.info('foo')
        end

      expect(output).to match(/foo/)
    end

    describe 'custom level option' do
      it 'takes a integer' do
        logger = Hanami::Logger.new(level: 3)
        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a integer more than 5' do
        logger = Hanami::Logger.new(level: 99)
        expect(logger.level).to eq Hanami::Logger::DEBUG
      end

      it 'takes a symbol' do
        logger = Hanami::Logger.new(level: :error)
        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a string' do
        logger = Hanami::Logger.new(level: 'error')
        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a string with strange value' do
        logger = Hanami::Logger.new(level: 'strange')
        expect(logger.level).to eq Hanami::Logger::DEBUG
      end

      it 'takes a uppercased string' do
        logger = Hanami::Logger.new(level: 'ERROR')
        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a constant' do
        logger = Hanami::Logger.new(level: Hanami::Logger::ERROR)
        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'contains debug level by default' do
        logger = Hanami::Logger.new
        expect(logger.level).to eq ::Logger::DEBUG
      end
    end

    describe 'custom stream' do
      describe 'file system' do
        before do
          Pathname.new(stream).dirname.mkpath
        end

        Hash[
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log').to_s => 'absolute path (string)',
          Pathname.new('tmp').join('logfile.log').to_s          => 'relative path (string)',
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log')      => 'absolute path (pathname)',
          Pathname.new('tmp').join('logfile.log')               => 'relative path (pathname)',
        ].each do |dev, desc|
          describe "when #{desc}" do
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
                expect(contents).to match(/newline/)
              end
            end

            describe 'and it already exists' do
              before do
                File.open(stream, File::WRONLY | File::TRUNC | File::CREAT, permissions) { |f| f.write('existing') }
              end

              let(:permissions) { 0o664 }

              it 'appends to file' do
                logger = Hanami::Logger.new(stream: stream)
                logger.info('appended')

                contents = File.read(stream)
                expect(contents).to match(/existing/)
                expect(contents).to match(/appended/)
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
          let(:permissions) { 0o644 }

          before(:each) do
            log_file.write('hello')
          end

          describe 'and already written' do
            it 'appends to file' do
              logger = Hanami::Logger.new(stream: log_file)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to match(/hello/)
              expect(contents).to match(/world/)
            end

            it 'does not change permissions'
            # it 'does not change permissions' do
            #   logger = Hanami::Logger.new(stream: log_file)
            #   logger.info('appended')
            #   logger.close

            #   stat = File.stat(log_file)
            #   mode = stat.mode.to_s(8)

            #   require 'hanami/utils'
            #   if Hanami::Utils.jruby?
            #     expect(mode).to eq('100664')
            #   else
            #     expect(mode).to eq('100644')
            #   end
            # end
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
            expect(contents).to match(/in file/)
          end
        end # end IO
      end # end FileSystem

      describe 'when StringIO' do
        let(:stream) { StringIO.new }

        it 'appends' do
          logger = Hanami::Logger.new(stream: stream)
          logger.info('in file')

          stream.rewind
          expect(stream.read).to match(/in file/)
        end
      end # end StringIO
    end # end #initialize

    describe '#close' do
      it 'does not close STDOUT output for other code' do
        logger = Hanami::Logger.new(stream: STDOUT)
        logger.close

        expect { print 'in STDOUT' }.to output('in STDOUT').to_stdout
      end

      it 'does not close $stdout output for other code' do
        logger = Hanami::Logger.new(stream: $stdout)
        logger.close

        expect { print 'in $stdout' }.to output('in $stdout').to_stdout
      end
    end

    describe '#level=' do
      subject(:logger) { Hanami::Logger.new }

      it 'takes a integer' do
        logger.level = 3

        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a integer more than 5' do
        logger.level = 99

        expect(logger.level).to eq Hanami::Logger::DEBUG
      end

      it 'takes a symbol' do
        logger.level = :error

        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a string' do
        logger.level = 'error'

        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a string with strange value' do
        logger.level = 'strange'

        expect(logger.level).to eq Hanami::Logger::DEBUG
      end

      it 'takes a uppercased string' do
        logger.level = 'ERROR'

        expect(logger.level).to eq Hanami::Logger::ERROR
      end

      it 'takes a constant' do
        logger.level = Hanami::Logger::ERROR

        expect(logger.level).to eq Hanami::Logger::ERROR
      end
    end

    it 'has application_name when log' do
      output =
        with_captured_stdout do
          module App; class TestLogger < Hanami::Logger; end; end
          logger = App::TestLogger.new
          logger.info('foo')
        end

      expect(output).to match(/App/)
    end

    it 'has default app tag when not in any namespace' do
      class TestLogger < Hanami::Logger; end
      expect(TestLogger.new.application_name).to eq 'hanami'
    end

    it 'infers apptag from namespace' do
      module App2
        class TestLogger < Hanami::Logger; end
        class Bar
          def hoge
            TestLogger.new.application_name
          end
        end
      end

      expect(App2::Bar.new.hoge).to eq 'App2'
    end

    it 'uses custom application_name from override class' do
      class TestLogger < Hanami::Logger
        def application_name
          'bar'
        end
      end

      output =
        with_captured_stdout do
          TestLogger.new.info('')
        end

      expect(output).to match(/bar/)
    end

    describe 'with nil formatter' do
      it 'falls back to Formatter' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new(formatter: nil).info('foo')
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo\n"
      end
    end

    describe 'with JSON formatter' do
      if Hanami::Utils.jruby?
        it 'when passed as a symbol, it has JSON format for string messages'
      else
        it 'when passed as a symbol, it has JSON format for string messages' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(formatter: :json).info('foo')
            end
          expect(output).to eq %({"app":"hanami","severity":"INFO","time":"2017-01-15T15:00:23Z","message":"foo"}\n)
        end
      end

      if Hanami::Utils.jruby?
        it 'has JSON format for string messages'
      else
        it 'has JSON format for string messages' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info('foo')
            end
          expect(output).to eq %({"app":"hanami","severity":"INFO","time":"2017-01-15T15:00:23Z","message":"foo"}\n)
        end
      end

      if Hanami::Utils.jruby?
        it 'has JSON format for error messages'
      else
        it 'has JSON format for error messages' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).error(Exception.new('foo'))
            end
          expect(output).to eq %({"app":"hanami","severity":"ERROR","time":"2017-01-15T15:00:23Z","message":"foo","backtrace":[],"error":"Exception"}\n)
        end
      end

      if Hanami::Utils.jruby?
        it 'has JSON format for hash messages'
      else
        it 'has JSON format for hash messages' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info(foo: :bar)
            end
          expect(output).to eq %({"app":"hanami","severity":"INFO","time":"2017-01-15T15:00:23Z","foo":"bar"}\n)
        end
      end

      if Hanami::Utils.jruby?
        it 'has JSON format for not string messages'
      else
        it 'has JSON format for not string messages' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(formatter: Hanami::Logger::JSONFormatter.new).info(['foo'])
            end
          expect(output).to eq %({"app":"hanami","severity":"INFO","time":"2017-01-15T15:00:23Z","message":["foo"]}\n)
        end
      end
    end

    describe 'with default formatter' do
      it 'when passed as a symbol, it has key=value format for string messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new(formatter: :default).info('foo')
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo\n"
      end

      it 'has key=value format for string messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info('foo')
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo\n"
      end

      it 'has key=value format for error messages' do
        exception = nil
        output = with_captured_stdout do
          class TestLogger < Hanami::Logger; end
          begin
            raise StandardError.new('foo')
          rescue => e
            exception = e
          end
          TestLogger.new.error(exception)
        end
        expectation = "[hanami] [ERROR] [2017-01-15 16:00:23 +0100] StandardError: foo\n"
        exception.backtrace.each do |line|
          expectation << "from #{line}\n"
        end
        expect(output).to eq expectation
      end

      it 'has key=value format for hash messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(foo: :bar)
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] bar\n"
      end

      it 'has key=value format for not string messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(%(foo bar))
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo bar\n"
      end

      it 'displays filtered hash values' do
        form_params = Hash[
          form_params: Hash[
            'name' => 'John',
            'password' => '[FILTERED]',
            'password_confirmation' => '[FILTERED]'
          ]
        ]

        expected = "{\"name\"=>\"John\", \"password\"=>\"[FILTERED]\", \"password_confirmation\"=>\"[FILTERED]\"}"

        output = with_captured_stdout do
          class TestLogger < Hanami::Logger; end
          TestLogger.new.info(form_params)
        end

        expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
      end
    end

    context do
      let(:form_params) do
        Hash[
          form_params: Hash[
            'name' => 'John',
            'password' => 'password',
            'password_confirmation' => 'password',
            'credit_card' => Hash[
              'number' => '4545 4545 4545 4545',
              'name' => 'John Citizen'
            ]
          ]
        ]
      end

      describe 'with filters' do
        it 'filters values for keys in the filters array' do
          expected = "{\"name\"=>\"John\", \"password\"=>\"[FILTERED]\", \"password_confirmation\"=>\"[FILTERED]\", \"credit_card\"=>\"[FILTERED]\"}"

          output = with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new(filter: [/.*password.*/, :credit_card]).info(form_params)
          end

          expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
        end
      end

      describe 'without filters' do
        it 'outputs unfiltered params' do
          expected = "{\"name\"=>\"John\", \"password\"=>\"password\", \"password_confirmation\"=>\"password\", \"credit_card\"=>{\"number\"=>\"4545 4545 4545 4545\", \"name\"=>\"John Citizen\"}}"

          output = with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(form_params)
          end

          expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
        end
      end
    end
  end
end
