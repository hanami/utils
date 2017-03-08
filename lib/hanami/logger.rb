require 'set'
require 'json'
require 'logger'
require 'hanami/utils/string'
require 'hanami/utils/json'
require 'hanami/utils/class_attribute'

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

      # @since 1.0.0.beta1
      # @api private
      RESERVED_KEYS = [:app, :severity, :time].freeze

      include Utils::ClassAttribute

      class_attribute :subclasses
      self.subclasses = Set.new

      def self.fabricate(formatter, application_name)
        case formatter
        when Symbol
          (subclasses.find { |s| s.eligible?(formatter) } || self).new
        when nil
          new
        else
          formatter
        end.tap { |f| f.application_name = application_name }
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

      # @since 0.5.0
      # @api private
      attr_writer :application_name

      # @since 1.0.0.beta1
      # @api private
      attr_reader :application_name

      # @since 0.5.0
      # @api private
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html#method-i-call
      def call(severity, time, _progname, msg)
        _format({
          app:      application_name,
          severity: severity,
          time:     time
        }.merge(
          _message_hash(msg)
        ))
      end

      private

      # @since 0.8.0
      # @api private
      def _message_hash(message) # rubocop:disable Metrics/MethodLength
        case message
        when Hash
          message
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
        result = RESERVED_KEYS.map { |k| "[#{hash[k]}]" }.join(SEPARATOR)
        return _format_error(result, hash) if hash.key?(:error)

        values = hash.each_with_object([]) do |(k, v), memo|
          memo << v unless RESERVED_KEYS.include?(k)
        end

        result << " #{values.join(SEPARATOR)}#{NEW_LINE}"
        result
      end

      # @api private
      def _format_error(result, hash)
        result << " #{hash[:error]}:" if hash.key?(:error)
        result << " #{hash[:message]}#{NEW_LINE}"
        if hash.key?(:backtrace)
          hash[:backtrace].each do |line|
            result << "from #{line}#{NEW_LINE}"
          end
        end

        result
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
    # @param stream [String, IO, StringIO, Pathname] an optional log stream. This is a filename
    # (String) or IO object (typically STDOUT, STDERR, or an open file).
    #
    # @since 0.5.0
    def initialize(application_name = nil, stream: STDOUT, level: DEBUG, formatter: nil)
      super(stream)

      @level            = _level(level)
      @stream           = stream
      @application_name = application_name
      @formatter        = Formatter.fabricate(formatter, self.application_name)
    end

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
