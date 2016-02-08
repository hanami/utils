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

    describe 'custom device' do
      describe 'file system' do
        before do
          Pathname.new(device).dirname.mkpath
        end

        Hash[
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log').to_s => "absolute path (string)",
          Pathname.new('tmp').join('logfile.log').to_s          => "relative path (string)",
          Pathname.new(Dir.pwd).join('tmp', 'logfile.log')      => "absolute path (pathname)",
          Pathname.new('tmp').join('logfile.log')               => "relative path (pathname)",
        ].each do |dev, desc|

          describe "when #{ desc }" do
            let(:device) { dev }

            after do
              File.delete(device)
            end

            describe 'and it does not exist' do
              before do
                File.delete(device) if File.exist?(device)
              end

              it 'writes to file' do
                logger = Hanami::Logger.new(device: device)
                logger.info('newline')

                contents = File.read(device)
                contents.must_match(/newline/)

                assert_permissions(device)
              end
            end

            describe 'and it already exists' do
              before do
                File.open(device, File::WRONLY|File::TRUNC|File::CREAT, permissions) {|f| f.write('existing') }
              end

              let(:permissions) { 0664 }

              it 'appends to file' do
                logger = Hanami::Logger.new(device: device)
                logger.info('appended')

                contents = File.read(device)
                contents.must_match(/existing/)
                contents.must_match(/appended/)
              end

              it 'does not change permissions' do
                logger = Hanami::Logger.new(device: device)
                logger.info('appended')

                if macosx?
                  assert_permissions(device)
                else
                  assert_permissions(device, "100#{ permissions.to_s(8) }")
                end
              end
            end
          end

        end # end loop

        describe 'when file' do
          let(:device) { File.new(Pathname.new('tmp').join('logfile.log'), 'w+', permissions) }
          let(:permissions) { 0644 }

          describe 'and brand new' do
            before do
              device.write('hello')
            end

            it 'appends to file' do
              logger = Hanami::Logger.new(device: device)
              logger.info('world')

              logger.close

              contents = File.read(device)
              contents.must_match(/hello/)
              contents.must_match(/world/)

              assert_permissions(device)
            end
          end

          describe 'and already written' do
            before do
              device.write('hello')
            end

            it 'appends to file' do
              logger = Hanami::Logger.new(device: device)
              logger.info('world')

              logger.close

              contents = File.read(device)
              contents.must_match(/hello/)
              contents.must_match(/world/)
            end

            it 'does not change permissions' do
              logger = Hanami::Logger.new(device: device)
              logger.info('appended')
              logger.close

              assert_permissions(device, "100#{ permissions.to_s(8) }")
            end
          end
        end # end File

        describe 'when IO' do
          let(:device) { Pathname.new('tmp').join('logfile.log').to_s }

          it 'appends' do
            fd = IO.sysopen(device, 'w')
            io = IO.new(fd, 'w')

            logger = Hanami::Logger.new(device: io)
            logger.info('in file')
            logger.close

            contents = File.read(device)
            contents.must_match(/in file/)
          end
        end # end IO

      end # end FileSystem

      describe 'when StringIO' do
        let(:device) { StringIO.new }

        it 'appends' do
          logger = Hanami::Logger.new(device: device)
          logger.info('in file')

          device.rewind
          device.read.must_match(/in file/)
        end
      end # end StringIO

    end # end #initialize


    describe "#close" do
      it 'does not close STDOUT output for other code' do
        logger = Hanami::Logger.new(device: STDOUT)
        logger.close

        assert_output('in STDOUT') { print 'in STDOUT' }
      end

      it 'does not close $stdout output for other code' do
        logger = Hanami::Logger.new(device: $stdout)
        logger.close

        assert_output('in $stdout') { print 'in $stdout' }
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

  private

  def macosx?
    RbConfig::CONFIG['host_os'].match(/darwin|mac os/)
  end

  def assert_permissions(file, permissions = '100644')
    stat = ::File::Stat.new(file)
    stat.mode.to_s(8).must_equal(permissions)
  end
end
