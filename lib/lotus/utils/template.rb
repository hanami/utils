require 'tilt'

module Lotus
  module Utils
    # A logic-less template.
    #
    # @api private
    # @since 0.1.0
    class Template
      def initialize(template, encoding = Encoding::UTF_8)
        @_template = Tilt.new(template, nil, default_encoding: encoding)
      end

      # Render the template within the context of the given scope.
      #
      # @param scope [Class] the rendering scope
      # @param locals [Hash] set of objects passed to the constructor
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      def render(scope = Object.new, locals = {}, &blk)
        @_template.render(scope, locals, &blk)
      end

      # Get the path to the template
      #
      # @return [String] the pathname
      #
      # @api private
      # @since 0.1.0
      def file
        @_template.file
      end

      # Returns the format that the template handles.
      #
      # @return [Symbol] the format name
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils'
      #
      #   template = Lotus::Utils::Template.new('index.html.erb')
      #   template.format # => :html
      def format
        @_template.basename.match(/\.([^.]+)/).captures.first.to_sym
      end
    end
  end
end
