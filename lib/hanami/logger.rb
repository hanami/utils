require 'logger'
require 'hanami/utils/string'

module Hanami
  # Hanami logger
  #
  # Implement with the same interface of Ruby std lib `Logger`.
  # It uses `STDOUT`, `STDERR`, file name or open file as output device.
  #
  #
  #
  # When a Hanami application is initialized, it creates a logger for that specific application.
  # For instance for a `Bookshelf::Application` a `Bookshelf::Logger` will be available.
  #
  # This is useful for auto-tagging the output. Eg (`[Booshelf]`).
  #
  # When used stand alone (eg. `Hanami::Logger.info`), it tags lines with `[Shared]`.
  #
  #
  #
  # The available severity levels are the same of `Logger`:
  #
  #   * debug
  #   * error
  #   * fatal
  #   * info
  #   * unknown
  #   * warn
  #
  # Those levels are available both as class and instance methods.
  #
  # @since 0.5.0
  #
  # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html
  # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Severity.html
  #
  # @example Basic usage
  #   require 'hanami'
  #
  #   module Bookshelf
  #     class Application < Hanami::Application
  #     end
  #   end
  #
  #   # Initialize the application with the following code:
  #   Bookshelf::Application.load!
  #   # or
  #   Bookshelf::Application.new
  #
  #   Bookshelf::Logger.info('Hello')
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [Bookshelf] : Hello
  #
  #   Bookshelf::Logger.new.info('Hello')
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [Bookshelf] : Hello
  #
  # @example Standalone usage
  #   require 'hanami'
  #
  #   Hanami::Logger.info('Hello')
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [Hanami] : Hello
  #
  #   Hanami::Logger.new.info('Hello')
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [Hanami] : Hello
  #
  # @example Custom tagging
  #   require 'hanami'
  #
  #   Hanami::Logger.new('FOO').info('Hello')
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [FOO] : Hello
  #
  # @example Write to file
  #   require 'hanami'
  #
  #   Hanami::Logger.new(log_device: 'logfile.log').info('Hello')
  #   # in logfile.log
  #   # => I, [2015-01-10T21:55:12.727259 #80487]  INFO -- [FOO] : Hello
  class Logger < ::Logger
    # Hanami::Logger default formatter
    #
    # @since 0.5.0
    # @api private
    #
    # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html
    class Formatter < ::Logger::Formatter
      # @since 0.5.0
      # @api private
      attr_writer :application_name

      # @since 0.5.0
      # @api private
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html#method-i-call
      def call(severity, time, progname, msg)
        progname = "[#{@application_name}] #{progname}"
        super(severity, time.utc, progname, msg)
      end
    end

    # Default application name.
    # This is used as a fallback for tagging purposes.
    #
    # @since 0.5.0
    # @api private
    DEFAULT_APPLICATION_NAME = 'Hanami'.freeze

    # @since 0.5.0
    # @api private
    attr_writer :application_name

    # Initialize a logger
    #
    # @param application_name [String] an optional application name used for
    #   tagging purposes
    #
    # @param log_device [String, IO] an optional log device. This is a filename
    # (String) or IO object (typically STDOUT, STDERR, or an open file).
    #
    # @since 0.5.0
    def initialize(application_name = nil, log_device: STDOUT)
      super(log_device)

      @log_device       = log_device
      @application_name = application_name
      @formatter        = Hanami::Logger::Formatter.new.tap { |f| f.application_name = self.application_name }
    end

    # Returns the current application name, this is used for tagging purposes
    #
    # @return [String] the application name
    #
    # @since 0.5.0
    def application_name
      @application_name || _application_name_from_namespace || _default_application_name
    end

    # Close the logging device if this device isn't an STDOUT
    #
    # @since x.x.x
    def close
      super if @log_device != STDOUT
    end

    private
    # @since 0.5.0
    # @api private
    def _application_name_from_namespace
      class_name = self.class.name
      namespace  = Utils::String.new(class_name).namespace

      class_name != namespace and return namespace
    end

    # @since 0.5.0
    # @api private
    def _default_application_name
      DEFAULT_APPLICATION_NAME
    end
  end
end
