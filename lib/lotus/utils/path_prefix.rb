require 'lotus/utils/string'
require 'lotus/utils/kernel'

module Lotus
  module Utils
    # Prefixed string
    #
    # @since 0.1.0
    class PathPrefix < Lotus::Utils::String
      # Path separator
      #
      # @since x.x.x
      # @api private
      DEFAULT_SEPARATOR = '/'.freeze

      # Initialize the path prefix
      #
      # @param string [::String] the prefix value
      # @param separator [::String] the separator used between tokens
      #
      # @return [PathPrefix] self
      #
      # @since 0.1.0
      #
      # @see Lotus::Utils::PathPrefix::DEFAULT_SEPARATOR
      def initialize(string = nil, separator = DEFAULT_SEPARATOR)
        super(string)
        @separator = separator
      end

      # Joins self with the given token.
      # It cleans up all the `separator` repetitions.
      #
      # @param string [::String] the token we want to join
      #
      # @return [Lotus::Utils::PathPrefix] the joined string
      #
      # @since 0.1.0
      #
      # @example Single string
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('/posts')
      #   path_prefix.join('new').to_s  # => "/posts/new"
      #   path_prefix.join('/new').to_s # => "/posts/new"
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('posts')
      #   path_prefix.join('new').to_s  # => "/posts/new"
      #   path_prefix.join('/new').to_s # => "/posts/new"
      #
      # @example Multiple strings
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('myapp')
      #   path_prefix.join('/assets', 'application.js').to_s
      #     # => "/myapp/assets/application.js"
      def join(*strings)
        relative_join(strings).absolute!
      end

      # Joins self with the given token, without prefixing it with `separator`.
      # It cleans up all the `separator` repetitions.
      #
      # @param string [::String] the token we want to join
      # @param separator [::String] the separator used between tokens
      #
      # @return [Lotus::Utils::PathPrefix] the joined string
      #
      # @raise [TypeError] if one of the argument can't be treated as a
      #   string
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new 'posts'
      #   path_prefix.relative_join('new').to_s      # => 'posts/new'
      #   path_prefix.relative_join('new', '_').to_s # => 'posts_new'
      def relative_join(strings, separator = @separator)
        raise TypeError if separator.nil?
        prefix = @string.gsub(@separator, separator)

        self.class.new(
          Utils::Kernel.Array([prefix, strings]).join(separator),
          separator
        ).relative!
      end

      # Returns the absolute version of the path prefix, that is with the
      # prepended separator.
      #
      # @return [Lotus::Utils::PathPrefix]
      #
      # @since 0.3.1
      #
      # @example
      #   require "lotus/utils/path_prefix"
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new("posts")
      #   path_prefix.to_s          #=> "posts"
      #   path_prefix.absolute.to_s #=> "/posts"
      def absolute
        dup.absolute!
      end

      # Modifies the path prefix to have a prepended separator.
      #
      # @return [self]
      #
      # @since 0.3.1
      #
      # @see #absolute
      def absolute!
        @string.prepend(separator) unless absolute?

        self
      end

      # Returns whether the path prefix starts with its separator.
      #
      # @return [Boolean]
      #
      # @since 0.3.1
      #
      # @example
      #   require "lotus/utils/path_prefix"
      #
      #   Lotus::Utils::PathPrefix.new("/posts").absolute? #=> true
      #   Lotus::Utils::PathPrefix.new("posts").absolute?  #=> false
      def absolute?
        @string.start_with?(separator)
      end

      # Returns the relative version of the path prefix, that is without
      # the leading separator.
      #
      # @return [Lotus::Utils::PathPrefix]
      #
      # @since 0.3.1
      #
      # @example
      #   require "lotus/utils/path_prefix"
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new("/posts")
      #   path_prefix.to_s          #=> "/posts"
      #   path_prefix.relative.to_s #=> "posts"
      def relative
        dup.relative!
      end

      # Modifies the path prefix to remove the leading separator.
      #
      # @return [self]
      #
      # @since 0.3.1
      #
      # @see #relative
      def relative!
        @string.gsub!(%r{(?<!:)#{ separator * 2 }}, separator)
        @string.sub!(%r{\A#{ separator }}, '')

        self
      end

      # Returns whether the path prefix doesn't start with its separator.
      #
      # @return [Boolean]
      #
      # @since 0.3.1
      #
      # @example
      #   require "lotus/utils/path_prefix"
      #
      #   Lotus::Utils::PathPrefix.new("posts").relative?   #=> true
      #   Lotus::Utils::PathPrefix.new("/posts").relative?  #=> false
      def relative?
        !absolute?
      end

      private
      # @since 0.1.0
      # @api private
      attr_reader :separator
    end
  end
end
