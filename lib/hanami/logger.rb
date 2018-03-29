require 'set'
require 'json'
require 'logger'
require 'hanami/utils/string'
require 'hanami/utils/json'
require 'hanami/utils/hash'
require 'hanami/utils/class_attribute'
require 'hanami/utils/files'
require 'hanami/utils/shell_color'

module Hanami
  # Hanami logger
  #
  # Implement with the same interface of Ruby std lib `Logger`.
  # It uses `STDOUT`, `STDERR`, file name or open file as output stream.
  #
  #
  # When a Hanami application is initialized, it creates a logger for that specific application.
  # For instance for a `Bookshelf::Application` a `Bookshelf::Logger` will be available.
  #
  # This is useful for auto-tagging the output. Eg (`app=Booshelf`).
  #
  # When used stand alone (eg. `Hanami::Logger.info`), it tags lines with `app=Shared`.
  #
  #
  # The available severity levels are the same of `Logger`:
  #
  #   * DEBUG
  #   * INFO
  #   * WARN
  #   * ERROR
  #   * FATAL
  #   * UNKNOWN
  #
  # Those levels are available both as class and instance methods.
  #
  # Also Hanami::Logger support different formatters. Now available only two:
  #
  #   * Formatter (default)
  #   * JSONFormatter
  #
  # And if you want to use custom formatter you need create new class inherited from
  # `Formatter` class and define `_format` private method like this:
  #
  #     class CustomFormatter < Formatter
  #       private
  #       def _format(hash)
  #         # ...
  #       end
  #     end
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
  #   Bookshelf::Logger.new.info('Hello')
  #   # => app=Bookshelf severity=INFO time=1988-09-01 00:00:00 UTC message=Hello
  #
  # @example Standalone usage
  #   require 'hanami/logger'
  #
  #   Hanami::Logger.new.info('Hello')
  #   # => app=Hanami severity=INFO time=2016-05-27 10:14:42 UTC message=Hello
  #
  # @example Custom tagging
  #   require 'hanami/logger'
  #
  #   Hanami::Logger.new('FOO').info('Hello')
  #   # => app=FOO severity=INFO time=2016-05-27 10:14:42 UTC message=Hello
  #
  # @example Write to file
  #   require 'hanami'
  #
  #   Hanami::Logger.new(stream: 'logfile.log').info('Hello')
  #   # in logfile.log
  #   # => app=FOO severity=INFO time=2016-05-27 10:14:42 UTC message=Hello
  #
  # @example Use JSON formatter
  #   require 'hanami'
  #
  #   Hanami::Logger.new(formatter: Hanami::Logger::JSONFormatter).info('Hello')
  #   # => "{\"app\":\"Hanami\",\"severity\":\"INFO\",\"time\":\"1988-09-01 00:00:00 UTC\",\"message\":\"Hello\"}"
  class Logger < ::Logger
    # Hanami::Logger default formatter.
    # This formatter returns string in key=value format.
    #
    # @since 0.5.0
    # @api private
    #
    # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html
    class Formatter < ::Logger::Formatter
      # @since 0.8.0
      # @api private
      SEPARATOR = ' '.freeze

      # @since 0.8.0
      # @api private
      NEW_LINE = $/

      # @since 1.0.0
      # @api private
      RESERVED_KEYS = %i[app severity time].freeze

      include Utils::ClassAttribute

      class_attribute :subclasses
      self.subclasses = Set.new

      def self.fabricate(formatter, application_name, filters, colorizer: NullColorizer.new)
        fabricated_formatter = _formatter_instance(formatter)

        fabricated_formatter.application_name = application_name
        fabricated_formatter.hash_filter      = HashFilter.new(filters)
        fabricated_formatter.colorizer        = colorizer

        fabricated_formatter
      end

      # @api private
      def self.inherited(subclass)
        super
        subclasses << subclass
      end

      # @api private
      def self.eligible?(name)
        name == :default
      end

      # @api private
      # @since 1.1.0
      def self._formatter_instance(formatter)
        case formatter
        when Symbol
          (subclasses.find { |s| s.eligible?(formatter) } || self).new
        when nil
          new
        else
          formatter
        end
      end
      private_class_method :_formatter_instance

      # @since 0.5.0
      # @api private
      attr_writer :application_name

      # @since 1.0.0
      # @api private
      attr_reader :application_name

      # @since 1.1.0
      # @api private
      attr_writer :hash_filter

      # @since x.x.x
      # @api private
      attr_writer :colorizer

      # @since 0.5.0
      # @api private
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html#method-i-call
      def call(severity, time, progname, msg)
        colorized = @colorizer.call(application_name, severity, time, progname)
        colorized.delete(:progname)
        _format(colorized.merge(_message_hash(msg)))
      end

      private

      # @since 0.8.0
      # @api private
      def _message_hash(message) # rubocop:disable Metrics/MethodLength
        case message
        when Hash
          @hash_filter.filter(message)
        when Exception
          Hash[
            message:   message.message,
            backtrace: message.backtrace || [],
            error:     message.class
          ]
        else
          Hash[message: message]
        end
      end

      # @since 0.8.0
      # @api private
      def _format(hash)
        [
          _line_front_matter(hash[:app], hash[:severity], hash[:time]),
          _format_message(hash)
        ].join(SEPARATOR)
      end

      # @since x.x.x
      # @api private
      def _line_front_matter(*args)
        args.map { |string| "[#{string}]" }.join(SEPARATOR)
      end

      # @since x.x.x
      # @api private
      def _format_message(hash)
        if hash.key?(:error)
          _format_error(hash)
        else
          hash.each_with_object([]) do |(k, v), memo|
            memo << v unless RESERVED_KEYS.include?(k)
          end.join(SEPARATOR).concat(NEW_LINE)
        end
      end

      # @since x.x.x
      # @api private
      def _format_error(hash)
        result = [hash[:error], hash[:message]].compact.join(": ").concat(NEW_LINE)
        hash[:backtrace].each do |line|
          result << "from #{line}#{NEW_LINE}"
        end

        result
      end

      # Filtering logic
      #
      # @since 1.1.0
      # @api private
      class HashFilter
        # @since 1.1.0
        # @api private
        attr_reader :filters

        # @since 1.1.0
        # @api private
        def initialize(filters = [])
          @filters = filters
        end

        # @since 1.1.0
        # @api private
        def filter(hash)
          _filtered_keys(hash).each do |key|
            *keys, last = _actual_keys(hash, key.split('.'))
            keys.inject(hash, :fetch)[last] = '[FILTERED]'
          end

          hash
        end

        private

        # @since 1.1.0
        # @api private
        def _filtered_keys(hash)
          _key_paths(hash).select { |key| filters.any? { |filter| key =~ %r{(\.|\A)#{filter}(\.|\z)} } }
        end

        # @since 1.1.0
        # @api private
        def _key_paths(hash, base = nil)
          hash.inject([]) do |results, (k, v)|
            results + (v.respond_to?(:each) ? _key_paths(v, _build_path(base, k)) : [_build_path(base, k)])
          end
        end

        # @since 1.1.0
        # @api private
        def _build_path(base, key)
          [base, key.to_s].compact.join('.')
        end

        # @since 1.1.0
        # @api private
        def _actual_keys(hash, keys)
          search_in = hash

          keys.inject([]) do |res, key|
            correct_key = search_in.key?(key.to_sym) ? key.to_sym : key
            search_in = search_in[correct_key]
            res + [correct_key]
          end
        end
      end
    end

    # Hanami::Logger JSON formatter.
    # This formatter returns string in JSON format.
    #
    # @since 0.5.0
    # @api private
    class JSONFormatter < Formatter
      # @api private
      def self.eligible?(name)
        name == :json
      end

      private

      # @since 0.8.0
      # @api private
      def _format(hash)
        hash[:time] = hash[:time].utc.iso8601
        Hanami::Utils::Json.generate(hash) + NEW_LINE
      end
    end

    # Hanami::Logger NullColorizer
    # This colorizer does nothing. It should be used when writing to a file, or
    # whenever you're not using a tty.
    #
    # When creating a new Colorizer, you should inherit from this class,
    # and define your own `_severity`, `_datetime`, `_progname` and `_msg`
    # methods.
    #
    # @since x.x.x
    # @api private
    class NullColorizer
      # @since x.x.x
      # @api private
      def call(app, severity, datetime, progname)
        {
          app:      _app(app),
          severity: _severity(severity),
          time:     _datetime(datetime),
          progname: _progname(progname)
        }
      end

      private

      # @since x.x.x
      # @api public
      def _app(input)
        input
      end

      # @since x.x.x
      # @api public
      def _severity(input)
        input
      end

      # @since x.x.x
      # @api public
      def _datetime(input)
        input
      end

      # @since x.x.x
      # @api public
      def _progname(input)
        input
      end
    end

    # Hanami::Logger DEfault Colorizer
    # This colorizer takes in parts of the log message and returns them with
    # proper shellcode to colorize when displayed to a tty.
    #
    # @since x.x.x
    # @api private
    class DefaultColorizer < NullColorizer
      # The colors defined for the four parts of the log message
      #
      # These can be overridden, keeping the name keys, with acceptable values
      # being any from Hanami::Utils::ShellColor::COLORS
      #
      # @since x.x.x
      # @api public
      COLORS = Hash[
        app:      :yellow,
        severity: :cyan,
        datetime: :green,
        progname: nil,
      ].freeze

      private

      # @since x.x.x
      # @api private
      def _app(input)
        _colorized(input, color: COLORS.fetch(:app))
      end

      # @since x.x.x
      # @api private
      def _severity(input)
        _colorized(input, color: COLORS.fetch(:severity))
      end

      # @since x.x.x
      # @api private
      def _datetime(input)
        _colorized(input, color: COLORS.fetch(:datetime))
      end

      # @since x.x.x
      # @api private
      def _progname(input)
        _colorized(input, color: COLORS.fetch(:progname))
      end

      # @since x.x.x
      # @api private
      def _colorized(message, color:)
        if color
          Hanami::Utils::ShellColor.call(message, color: color)
        else
          message
        end
      end
    end

    # Default application name.
    # This is used as a fallback for tagging purposes.
    #
    # @since 0.5.0
    # @api private
    DEFAULT_APPLICATION_NAME = 'hanami'.freeze

    # @since 0.8.0
    # @api private
    LEVELS = Hash[
      'debug'   => DEBUG,
      'info'    => INFO,
      'warn'    => WARN,
      'error'   => ERROR,
      'fatal'   => FATAL,
      'unknown' => UNKNOWN
    ].freeze

    # @since 0.5.0
    # @api private
    attr_writer :application_name

    # Initialize a logger
    #
    # @param application_name [String] an optional application name used for
    #   tagging purposes
    #
    # @param args [Array<Object>] an optional set of arguments to honor Ruby's
    #   `Logger#initialize` arguments. See Ruby documentation for details.
    #
    # @param stream [String, IO, StringIO, Pathname] an optional log stream.
    #   This is a filename (`String`) or `IO` object (typically `$stdout`,
    #   `$stderr`, or an open file). It defaults to `$stderr`.
    #
    # @param level [Integer,String] logging level. It can be expressed as an
    #   integer, according to Ruby's `Logger` from standard library or as a
    #   string with the name of the level
    #
    # @param formatter [Symbol,#_format] a formatter - We support `:json` as
    #   JSON formatter or an object that respond to `#_format(data)`
    #
    # @since 0.5.0
    #
    # @see https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html#class-Logger-label-How+to+create+a+logger
    #
    # @example Basic usage
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new
    #   logger.info "Hello World"
    #
    #   # => [Hanami] [DEBUG] [2017-03-30 15:41:01 +0200] Hello World
    #
    # @example Custom application name
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new('bookshelf')
    #   logger.info "Hello World"
    #
    #   # => [bookshelf] [DEBUG] [2017-03-30 15:44:23 +0200] Hello World
    #
    # @example Logger level (Integer)
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new(level: 2) # WARN
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.warn "Hello World"
    #   # => [Hanami] [WARN] [2017-03-30 16:00:48 +0200] Hello World
    #
    # @example Logger level (Constant)
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new(level: Hanami::Logger::WARN)
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.warn "Hello World"
    #   # => [Hanami] [WARN] [2017-03-30 16:00:48 +0200] Hello World
    #
    # @example Logger level (String)
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new(level: 'warn')
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.info "Hello World"
    #   # => true
    #
    #   logger.warn "Hello World"
    #   # => [Hanami] [WARN] [2017-03-30 16:00:48 +0200] Hello World
    #
    # @example Use a file
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new(stream: "development.log")
    #   logger.info "Hello World"
    #
    #   # => true
    #
    #   File.read("development.log")
    #   # =>
    #   #  # Logfile created on 2017-03-30 15:52:48 +0200 by logger.rb/56815
    #   #  [Hanami] [DEBUG] [2017-03-30 15:52:54 +0200] Hello World
    #
    # @example Period rotation
    #   require 'hanami/logger'
    #
    #   # Rotate daily
    #   logger = Hanami::Logger.new('bookshelf', 'daily', stream: 'development.log')
    #
    # @example File size rotation
    #   require 'hanami/logger'
    #
    #   # leave 10 old log files where the size is about 1,024,000 bytes
    #   logger = Hanami::Logger.new('bookshelf', 10, 1024000, stream: 'development.log')
    #
    # @example Use a StringIO
    #   require 'hanami/logger'
    #
    #   stream = StringIO.new
    #   logger = Hanami::Logger.new(stream: stream)
    #   logger.info "Hello World"
    #
    #   # => true
    #
    #   stream.rewind
    #   stream.read
    #
    #   # => "[Hanami] [DEBUG] [2017-03-30 15:55:22 +0200] Hello World\n"
    #
    # @example JSON formatter
    #   require 'hanami/logger'
    #
    #   logger = Hanami::Logger.new(formatter: :json)
    #   logger.info "Hello World"
    #
    #   # => {"app":"Hanami","severity":"DEBUG","time":"2017-03-30T13:57:59Z","message":"Hello World"}
    # rubocop:disable Lint/HandleExceptions
    # rubocop:disable Metrics/ParameterLists
    def initialize(application_name = nil, *args, stream: $stdout, level: DEBUG, formatter: nil, filter: [], colorizer: nil)
      begin
        Utils::Files.mkdir_p(stream)
      rescue TypeError
      end

      super(stream, *args)

      colorizer       ||= default_colorizer
      @level            = _level(level)
      @stream           = stream
      @application_name = application_name
      @formatter        = Formatter.fabricate(formatter, self.application_name, filter, colorizer: colorizer)
    end

    # @since x.x.x
    # @api private
    def tty?
      @logdev.dev.tty?
    end

    # @since x.x.x
    # @api private
    def default_colorizer
      (tty? && DefaultColorizer.new) || NullColorizer.new
    end

    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Lint/HandleExceptions

    # Returns the current application name, this is used for tagging purposes
    #
    # @return [String] the application name
    #
    # @since 0.5.0
    def application_name
      @application_name || _application_name_from_namespace || _default_application_name
    end

    # @since 0.8.0
    # @api private
    def level=(value)
      super _level(value)
    end

    # Close the logging stream if this stream isn't an STDOUT
    #
    # @since 0.8.0
    def close
      super unless [STDOUT, $stdout].include?(@stream)
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

    # @since 0.8.0
    # @api private
    def _level(level)
      case level
      when DEBUG..UNKNOWN
        level
      else
        LEVELS.fetch(level.to_s.downcase, DEBUG)
      end
    end
  end
end
