require 'hanami/logger'
require 'rbconfig'
require 'securerandom'

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

          describe 'colorization setting' do
            it 'colorizes when colorizer: Colorizer.new' do
              logger = Hanami::Logger.new(stream: log_file, colorizer: Hanami::Logger::Colorizer.new)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to include(
                "hello[\e[33mHanami\e[0m] [\e[36mINFO\e[0m] [\e[32m2017-01-15 16:00:23 +0100\e[0m] world"
              )
            end

            it 'colorizes when using custom colors: Colorizer.new' do
              logger = Hanami::Logger.new(stream: log_file, colorizer: Hanami::Logger::Colorizer.new(colors: { app: :red }))
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to include(
                "hello[\e[31mHanami\e[0m] [INFO] [2017-01-15 16:00:23 +0100] world"
              )
            end

            it 'does not colorize by default (since not tty)' do
              logger = Hanami::Logger.new(stream: log_file)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to eq(
                "hello[Hanami] [INFO] [2017-01-15 16:00:23 +0100] world\n"
              )
            end

            it 'does not colorize with colorizer: nil (since not tty)' do
              logger = Hanami::Logger.new(stream: log_file, colorizer: nil)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to eq(
                "hello[Hanami] [INFO] [2017-01-15 16:00:23 +0100] world\n"
              )
            end

            it 'does not colorize with colorizer: NullColorizer.new' do
              logger = Hanami::Logger.new(stream: log_file, colorizer: Hanami::Logger::NullColorizer.new)
              logger.info('world')

              logger.close

              contents = File.read(log_file)
              expect(contents).to eq(
                "hello[Hanami] [INFO] [2017-01-15 16:00:23 +0100] world\n"
              )
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
            expect(contents).to match(/in file/)
          end
        end # end IO
      end # end FileSystem

      describe 'file system with non-existing directory' do
        let(:stream) { Pathname.new(__dir__).join('..', '..', '..', 'tmp', SecureRandom.hex(16), 'logfile.log') }

        it 'creates the directory' do
          logger = Hanami::Logger.new(stream: stream)
          logger.info('hello world')

          logger.close

          contents = File.read(stream.to_s)
          expect(contents).to match(/hello world/)
        end
      end

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

      it 'has key=value format for hash messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(foo: "bar")
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo=bar\n"
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

      it 'has key=value format for error messages without backtrace' do
        exception = nil
        output = with_captured_stdout do
          class TestLogger < Hanami::Logger; end
          exception = StandardError.new('foo')
          TestLogger.new.error(exception)
        end
        expectation = "[hanami] [ERROR] [2017-01-15 16:00:23 +0100] StandardError: foo\n"
        expect(output).to eq expectation
      end

      describe 'colorization setting' do
        it 'colorizes when colorizer: Colorizer.new' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(colorizer: Hanami::Logger::Colorizer.new).info('foo')
            end
          expect(output).to eq(
            "[\e[33mhanami\e[0m] [\e[36mINFO\e[0m] [\e[32m2017-01-15 16:00:23 +0100\e[0m] foo\n"
          )
        end

        it 'colorizes when for tty by default (i.e. when colorizer: nil)' do
          stdout = IO.new($stdout.fileno)
          expect(stdout).to receive(:write).with(
            "[\e[33mhanami\e[0m] [\e[36mINFO\e[0m] [\e[32m2017-01-15 16:00:23 +0100\e[0m] foo\n"
          )
          class TestLogger < Hanami::Logger; end
          TestLogger.new(stream: stdout).info('foo')
        end

        it 'colorizes for tty when colorizer: nil' do
          stdout = IO.new($stdout.fileno)
          expect(stdout).to receive(:write).with(
            "[\e[33mhanami\e[0m] [\e[36mINFO\e[0m] [\e[32m2017-01-15 16:00:23 +0100\e[0m] foo\n"
          )
          class TestLogger < Hanami::Logger; end
          TestLogger.new(stream: stdout, colorizer: nil).info('foo')
        end

        it 'does not colorize when colorizer: NullColorizer.new' do
          output =
            with_captured_stdout do
              class TestLogger < Hanami::Logger; end
              TestLogger.new(colorizer: Hanami::Logger::NullColorizer.new).info('foo')
            end
          expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo\n"
        end
      end

      it 'has key=value format for hash messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(foo: :bar)
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo=bar\n"
      end

      it 'has key=value format for not string messages' do
        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(%(foo bar))
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] foo bar\n"
      end

      it 'logs HTTP request' do
        message = { http: "HTTP/1.1", verb: "GET", status: "200", ip: "::1", path: "/books/23", length: "175", params: {}, elapsed: 0.005829 }

        output =
          with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(message)
          end
        expect(output).to eq "[hanami] [INFO] [2017-01-15 16:00:23 +0100] HTTP/1.1 GET 200 ::1 /books/23 175 {} 0.005829\n"
      end

      it 'displays filtered hash values' do
        params = Hash[
          params: Hash[
            'name' => 'John',
            'password' => '[FILTERED]',
            'password_confirmation' => '[FILTERED]'
          ]
        ]

        expected = "{\"name\"=>\"John\", \"password\"=>\"[FILTERED]\", \"password_confirmation\"=>\"[FILTERED]\"}"

        output = with_captured_stdout do
          class TestLogger < Hanami::Logger; end
          TestLogger.new.info(params)
        end

        expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
      end
    end

    context do
      let(:params) do
        Hash[
          params: Hash[
            'password' => 'password',
            'password_confirmation' => 'password',
            'credit_card' => Hash[
              'number' => '4545 4545 4545 4545',
              'name' => 'John Citizen'
            ],
            'user' => Hash[
              'login' => 'John',
              'name'  => 'John'
            ]
          ]
        ]
      end

      describe 'with filters' do
        it 'filters values for keys in the filters array' do
          expected = %s({"password"=>"[FILTERED]", "password_confirmation"=>"[FILTERED]", "credit_card"=>{"number"=>"[FILTERED]", "name"=>"[FILTERED]"}, "user"=>{"login"=>"[FILTERED]", "name"=>"John"}})

          output = with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            filters = %w[password password_confirmation credit_card user.login]
            TestLogger.new(filter: filters).info(params)
          end

          expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
        end
      end

      describe 'without filters' do
        it 'outputs unfiltered params' do
          expected = %s({"password"=>"password", "password_confirmation"=>"password", "credit_card"=>{"number"=>"4545 4545 4545 4545", "name"=>"John Citizen"}, "user"=>{"login"=>"John", "name"=>"John"}})

          output = with_captured_stdout do
            class TestLogger < Hanami::Logger; end
            TestLogger.new.info(params)
          end

          expect(output).to eq("[hanami] [INFO] [2017-01-15 16:00:23 +0100] #{expected}\n")
        end
      end
    end
  end

  describe Hanami::Logger::Filter do
    context 'without filters' do
      it "doesn't filter" do
        input = Hash[password: 'azerty']
        output = described_class.new.call(input)
        expect(output).to eql(input)
      end
    end

    it "doesn't alter the hash keys" do
      output = described_class.new(%w[password]).call(Hash["password" => 'azerty', foo: Hash[password: 'bar']])
      expect(output).to eql(Hash["password" => '[FILTERED]', foo: Hash[password: '[FILTERED]']])
    end

    it 'filters with multiple filters' do
      input = Hash[password: 'azerty', number: '12345']
      output = described_class.new(%i[password number]).call(input)
      expect(output).to eql(Hash[password: '[FILTERED]', number: '[FILTERED]'])
    end

    it 'filters with multi-level filter' do
      input = Hash[user: Hash[name: 'foo', password: 'azerty'], password: 'foo']
      output = described_class.new(%w[user.password]).call(input)
      expect(output).to eql(Hash[user: Hash[name: 'foo', password: '[FILTERED]'], password: 'foo'])
    end
  end
end
