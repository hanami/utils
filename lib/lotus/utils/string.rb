module Lotus
  module Utils
    # String on steroids
    #
    # @since 0.1.0
    class String
      # Separator between Ruby namespaces
      #
      # @since 0.1.0
      # @api private
      NAMESPACE_SEPARATOR = '::'.freeze

      # Separator for #classify
      #
      # @since 0.3.0
      # @api private
      CLASSIFY_SEPARATOR  = '_'.freeze

      # Regexp for #tokenize
      #
      # @since 0.3.0
      # @api private
      TOKENIZE_REGEXP     = /\((.*)\)/

      # Separator for #tokenize
      #
      # @since 0.3.0
      # @api private
      TOKENIZE_SEPARATOR  = '|'.freeze

      # Separator for #underscore
      #
      # @since 0.3.0
      # @api private
      UNDERSCORE_SEPARATOR = "/".freeze

      # gsub second parameter used in #underscore
      #
      # @since 0.3.0
      # @api private
      UNDERSCORE_DIVISION_TARGET  = '\1_\2'.freeze

      # Separator for #titleize
      #
      # @since x.x.x
      # @api private
      TITLEIZE_SEPARATOR = ' '.freeze

      # Initialize the string
      #
      # @param string [::String, Symbol] the value we want to initialize
      #
      # @return [String] self
      #
      # @since 0.1.0
      def initialize(string)
        @string = string.to_s
      end

      # Return a titleized version of the string
      #
      # @return [Lotus::Utils::String] the transformed string
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'lotus utils'
      #   string.titleize # => "Lotus Utils"
      def titleize
        self.class.new underscore.split(CLASSIFY_SEPARATOR).map(&:capitalize).join(TITLEIZE_SEPARATOR)
      end

      # Return a CamelCase version of the string
      #
      # @return [String] the transformed string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'lotus_utils'
      #   string.classify # => 'LotusUtils'
      def classify
        self.class.new split(CLASSIFY_SEPARATOR).map(&:capitalize).join
      end

      # Return a downcased and underscore separated version of the string
      #
      # Revised version of `ActiveSupport::Inflector.underscore` implementation
      # @see https://github.com/rails/rails/blob/feaa6e2048fe86bcf07e967d6e47b865e42e055b/activesupport/lib/active_support/inflector/methods.rb#L90
      #
      # @return [String] the transformed string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'LotusUtils'
      #   string.underscore # => 'lotus_utils'
      def underscore
        new_string = gsub(NAMESPACE_SEPARATOR, UNDERSCORE_SEPARATOR)
        new_string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, UNDERSCORE_DIVISION_TARGET)
        new_string.gsub!(/([a-z\d])([A-Z])/, UNDERSCORE_DIVISION_TARGET)
        new_string.gsub!(/[[:space:]]|\-/, UNDERSCORE_DIVISION_TARGET)
        new_string.downcase!
        self.class.new new_string
      end

      # Return the string without the Ruby namespace of the class
      #
      # @return [String] the transformed string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'Lotus::Utils::String'
      #   string.demodulize # => 'String'
      #
      #   string = Lotus::Utils::String.new 'String'
      #   string.demodulize # => 'String'
      def demodulize
        self.class.new split(NAMESPACE_SEPARATOR).last
      end

      # Return the top level namespace name
      #
      # @return [String] the transformed string
      #
      # @since 0.1.2
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'Lotus::Utils::String'
      #   string.namespace # => 'Lotus'
      #
      #   string = Lotus::Utils::String.new 'String'
      #   string.namespace # => 'String'
      def namespace
        self.class.new split(NAMESPACE_SEPARATOR).first
      end

      # It iterates through the tokens and calls the given block.
      # A token is a substring wrapped by `()` and separated by `|`.
      #
      # @yield the block that is called for each token.
      #
      # @return [void]
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/string'
      #
      #   string = Lotus::Utils::String.new 'Lotus::(Utils|App)'
      #   string.tokenize do |token|
      #     puts token
      #   end
      #
      #   # =>
      #     'Lotus::Utils'
      #     'Lotus::App'
      def tokenize
        if match = TOKENIZE_REGEXP.match(@string)
          pre, post = match.pre_match, match.post_match
          tokens = match[1].split(TOKENIZE_SEPARATOR)
          tokens.each do |token|
            yield(self.class.new("#{pre}#{token}#{post}"))
          end
        else
          yield(self.class.new(@string))
        end

        nil
      end

      # Returns the hash of the internal string
      #
      # @return [Fixnum]
      #
      # @since 0.3.0
      def hash
        @string.hash
      end

      # Returns a string representation
      #
      # @return [String]
      #
      # @since 0.3.0
      def to_s
        @string
      end

      alias_method :to_str,  :to_s

      # Equality
      #
      # @return [TrueClass,FalseClass]
      #
      # @since 0.3.0
      def ==(other)
        to_s == other
      end

      alias_method :eql?, :==

      # Split the string with the given pattern
      #
      # @return [Array<String>]
      #
      # @see http://www.ruby-doc.org/core/String.html#method-i-split
      #
      # @since 0.3.0
      def split(pattern, limit = 0)
        @string.split(pattern, limit)
      end

      # Replace the given pattern with the given replacement
      #
      # @return [String,nil]
      #
      # @see http://www.ruby-doc.org/core/String.html#method-i-gsub
      #
      # @since 0.3.0
      def gsub(pattern, replacement = nil, &blk)
        if block_given?
          @string.gsub(pattern, &blk)
        else
          @string.gsub(pattern, replacement)
        end
      end

      # Override Ruby's method_missing in order to provide ::String interface
      #
      # @api private
      # @since 0.3.0
      #
      # @raise [NoMethodError] If doesn't respond to the given method
      def method_missing(m, *args, &blk)
        if respond_to?(m)
          s = @string.__send__(m, *args, &blk)
          s = self.class.new(s) if s.is_a?(::String)
          s
        else
          raise NoMethodError.new(%(undefined method `#{ m }' for "#{ @string }":#{ self.class }))
        end
      end

      # Override Ruby's respond_to_missing? in order to support ::String interface
      #
      # @api private
      # @since 0.3.0
      def respond_to_missing?(m, include_private=false)
        @string.respond_to?(m, include_private)
      end
    end
  end
end
