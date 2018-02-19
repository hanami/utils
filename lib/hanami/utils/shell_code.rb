require 'transproc'

module Hanami
  module Utils
    class ShellCode
      # Escape codes for terminals to output strings in colors
      #
      # @since x.x.x
      # @api private
      COLORS = Hash[
        black:   30,
        red:     31,
        green:   32,
        yellow:  33,
        blue:    34,
        magenta: 35,
        cyan:    36,
        gray:    37,
      ].freeze

      # Colorize output
      # 8 colors available: black, red, green, yellow, blue, magenta, cyan, and gray
      #
      # @api public
      # @since x.x.x
      def self.colorize(input, color:)
        "\e[#{color_code(color)}m#{input}\e[0m"
      end

      # Helper method to translate between color names and terminal escape codes
      #
      # @api private
      # @since x.x.x
      def self.color_code(name)
        COLORS.fetch(name)
      end
    end
  end
end
