module Lotus
  module Utils
    module Escape
      HTML_CHARS = {
        '&' => '&amp;',
        '<' => '&lt;',
        '>' => '&rt;',
        '"' => '&quot;',
        "'" => '&apos;',
        '/' => '&#x2F'
      }.freeze

      def self.escape_html(input)
        # TODO bech this guard vs input.to_s.encode
        return nil if input.nil?

        result = ""
        input.encode(Encoding::UTF_8).chars do |chr|
          result << HTML_CHARS.fetch(chr, chr)
        end

        result
      end
    end
  end
end
