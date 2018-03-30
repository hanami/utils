# frozen_string_literal: true

require "logger"
require "hanami/utils/shell_color"

module Hanami
  class Logger < ::Logger
    # Null colorizer for logger streams that aren't a TTY (eg. files)
    #
    # @since 1.2.0
    # @api private
    class NullColorizer
      # @since 1.2.0
      # @api private
      def call(app, severity, datetime, _progname)
        ::Hash[
          app:      app,
          severity: severity,
          time:     datetime,
        ]
      end
    end

    # Hanami::Logger Default Colorizer
    #
    # This colorizer takes in parts of the log message and returns them with
    # proper shellcode to colorize when displayed to a tty.
    #
    # @since 1.2.0
    # @api private
    class Colorizer < NullColorizer
      def initialize(colors: COLORS)
        @colors = colors
      end

      # Colorize the inputs
      #
      # @param app [#to_s] the app name
      # @param severity [#to_s] log severity
      # @param datetime [#to_s] timestamp
      # @param _progname [#to_s] program name - ignored, accepted for
      #   compatibility with Ruby's Logger
      #
      # @return [::Hash] an Hash containing the keys `:app`, `:severity`, and `:time`
      def call(app, severity, datetime, _progname)
        ::Hash[
          app:      app(app),
          severity: severity(severity),
          time:     datetime(datetime),
        ]
      end

      private

      # The colors defined for the four parts of the log message
      #
      # These can be overridden, keeping the name keys, with acceptable values
      # being any from Hanami::Utils::ShellColor::COLORS
      #
      # @since 1.2.0
      COLORS = ::Hash[
        app:      :yellow,
        severity: :cyan,
        datetime: :green,
      ].freeze

      attr_reader :colors

      # @since 1.2.0
      # @api private
      def app(input)
        colorize(input, color: colors.fetch(:app, nil))
      end

      # @since 1.2.0
      # @api private
      def severity(input)
        colorize(input, color: colors.fetch(:severity, nil))
      end

      # @since 1.2.0
      # @api private
      def datetime(input)
        colorize(input, color: colors.fetch(:datetime, nil))
      end

      # @since 1.2.0
      # @api private
      def colorize(message, color:)
        return message if color.nil?
        Hanami::Utils::ShellColor.call(message, color: color)
      end
    end
  end
end
