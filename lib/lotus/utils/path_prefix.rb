require 'lotus/utils/string'

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
      # @return [::String] the joined string
      #
      # @since 0.1.0
      #
      # @example Single string
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('/posts')
      #   path_prefix.join('new')  # => "/posts/new"
      #   path_prefix.join('/new') # => "/posts/new"
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('posts')
      #   path_prefix.join('new')  # => "/posts/new"
      #   path_prefix.join('/new') # => "/posts/new"
      #
      # @example Multiple strings
      #   require 'lotus/utils/path_prefix'
      #
      #   path_prefix = Lotus::Utils::PathPrefix.new('myapp')
      #   path_prefix.join('/assets', 'application.js')
      #     # => "/myapp/assets/application.js"
      def join(*strings)
        absolutize relative_join(strings)
      end

      # Joins self with the given token, without prefixing it with `separator`.
      # It cleans up all the `separator` repetitions.
      #
      # @param string [::String] the token we want to join
      # @param separator [::String] the separator used between tokens
      #
      # @return [::String] the joined string
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
      #   path_prefix.relative_join 'new'      # => 'posts/new'
      #   path_prefix.relative_join 'new', '_' # => 'posts_new'
      def relative_join(strings, separator = @separator)
        raise TypeError if separator.nil?

        self.class.new(
          relativize(
            [@string.gsub(@separator, separator), strings].join(separator),
            separator
          ),
          @separator
        )
      end

      private
      # @since 0.1.0
      # @api private
      attr_reader :separator

      # @since 0.1.0
      # @api private
      def absolutize(string)
        string.tap do |s|
          s.prepend(separator) unless absolute?(s)
        end
      end

      # @since 0.1.0
      # @api private
      def absolute?(string)
        string.start_with?(separator)
      end

      # @since 0.1.0
      # @api private
      def relativize(string, separator = @separator)
        string.
          gsub(%r{(?<!:)#{ separator * 2 }}, separator).
          gsub(%r{\A#{ separator }}, '')
      end
    end
  end
end
