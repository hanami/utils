require 'lotus/utils/kernel'

module Lotus
  module Utils
    # A collection of loading paths.
    #
    # @since 0.2.0
    class LoadPaths
      # Initialize a new collection for the given paths
      #
      # @param paths [String, Pathname, Array<String>, Array<Pathname>] A single
      #   or a collection of objects that can be converted into a Pathname
      #
      # @return [Lotus::Utils::LoadPaths] self
      #
      # @since 0.2.0
      #
      # @see http://ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see Lotus::Utils::Kernel.Pathname
      def initialize(*paths)
        @paths = Array(paths)
      end

      # Iterates thru the collection and yields the given block.
      # It skips duplications and raises an error in case one of the paths
      # doesn't exist.
      #
      # @param blk [Proc] the block of code to be yielded
      #
      # @return [void]
      #
      # @raise [Errno::ENOENT] if one of the paths doesn't exist
      #
      # @since 0.2.0
      def each(&blk)
        Utils::Kernel.Array(@paths).each do |path|
          blk.call Utils::Kernel.Pathname(path).realpath
        end
      end

      # Adds the given path(s).
      #
      # It returns self, so that multiple operations can be performed.
      #
      # @param paths [String, Pathname, Array<String>, Array<Pathname>] A single
      #   or a collection of objects that can be converted into a Pathname
      #
      # @return [Lotus::Utils::LoadPaths] self
      #
      # @since 0.2.0
      #
      # @see http://ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see Lotus::Utils::Kernel.Pathname
      #
      # @example Basic usage
      #   require 'lotus/utils/load_paths'
      #
      #   paths = Lotus::Utils::LoadPaths.new
      #   paths.push '.'
      #   paths.push '..', '../..'
      #
      # @example Chainable calls
      #   require 'lotus/utils/load_paths'
      #
      #   paths = Lotus::Utils::LoadPaths.new
      #   paths.push('.')
      #        .push('..', '../..')
      #
      # @example Shovel alias (#<<)
      #   require 'lotus/utils/load_paths'
      #
      #   paths = Lotus::Utils::LoadPaths.new
      #   paths << '.'
      #   paths << ['..', '../..']
      #
      # @example Chainable calls with shovel alias (#<<)
      #   require 'lotus/utils/load_paths'
      #
      #   paths = Lotus::Utils::LoadPaths.new
      #   paths << '.' << '../..'
      def push(*paths)
        @paths.push(*paths)
        self
      end

      alias_method :<<, :push
    end
  end
end
