module Lotus
  module Utils
    # String on steroids
    #
    # @since 0.1.0
    class String < ::String
      # Initialize the string
      #
      # @param string [::String, Symbol] the value we want to initialize
      #
      # @return [String] self
      #
      # @since 0.1.0
      def initialize(string)
        super(string.to_s)
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
        split('_').map {|token| token.slice(0).upcase + token.slice(1..-1) }.join
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
        gsub('::', '/').
          gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end

      # It iterates thru the tokens and calls the given block.
      # A token is a substring wrapped by `()` and separated by `|`.
      #
      # @param blk [Proc, #call] the block that is called for each token.
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
      def tokenize(&blk)
        template = gsub(/\((.*)\)/, "%{token}")
        tokens   = Array(( $1 || self ).split('|'))

        tokens.each do |token|
          blk.call(template % {token: token})
        end

        nil
      end
    end
  end
end
