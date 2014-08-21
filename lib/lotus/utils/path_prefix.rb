module Lotus
  module Utils
    # Prefixed string
    #
    # @since 0.1.0
    class PathPrefix
      # Initialize the path prefix
      #
      # @param string [::String] the prefix value
      # @param separator [::String] the separator used between tokens
      #
      # @return [PathPrefix] self
      #
      # @since 0.1.0
      def initialize(string = nil, separator = '/')
        @separator = separator
        @string    = string.to_s
      end

      # Joins self with the given token.
      # It cleans up all the `separator` repetitions.
      #
      # @param string [::String] the token we want to join
      #
      # @return [::String] the joined string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new '/posts'
      #   path_prefix.join 'new'  # => '/posts/new'
      #   path_prefix.join '/new' # => '/posts/new'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new 'posts'
      #   path_prefix.join 'new'  # => '/posts/new'
      #   path_prefix.join '/new' # => '/posts/new'
      def join(string)
        absolutize relative_join(string)
      end

      # Joins self with the given token, without prefixing it with `separator`.
      # It cleans up all the `separator` repetitions.
      #
      # @param string [::String] the token we want to join
      # @param separator [::String] the separator used between tokens
      #
      # @return [::String] the joined string
      #
      # @raise [ArgumentError] if one of the argument can't be treated as a
      #   string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new 'posts'
      #   path_prefix.relative_join 'new'      # => 'posts/new'
      #   path_prefix.relative_join 'new', '_' # => 'posts_new'
      def relative_join(string, separator = @separator)
        relativize [@string, string].join(separator), separator
      rescue NoMethodError
        raise ArgumentError
      end

      # Returns the hash of the internal string
      #
      # @return [Fixnum]
      #
      # @since x.x.x
      def hash
        @string.hash
      end

      # Returns a string representation
      #
      # @return [String]
      #
      # @since x.x.x
      def to_s
        @string
      end

      alias_method :to_str,  :to_s

      # Equality
      #
      # @return [TrueClass,FalseClass]
      #
      # @since x.x.x
      def ==(other)
        to_s == other
      end

      alias_method :eql?, :==

      private
      attr_reader :separator

      def absolutize(string)
        string.tap do |s|
          s.prepend(separator) unless absolute?(s)
        end
      end

      def absolute?(string)
        string.start_with?(separator)
      end

      def relativize(string, separator = @separator)
        string.
          gsub(%r{(?<!:)#{ separator * 2 }}, separator).
          gsub(%r{\A#{ separator }}, '')
      end
    end
  end
end
