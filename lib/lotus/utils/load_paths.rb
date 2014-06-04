require 'lotus/utils/kernel'

module Lotus
  module Utils
    # A collection of loading paths.
    #
    # @since 0.1.2
    class LoadPaths < Array
      # Initialize a new collection for the given paths
      #
      # @param paths [String, Pathname, Array<String>, Array<Pathname>] A single
      #   or a collection of objects that can be converted into a Pathname
      #
      # @return [Lotus::Utils::LoadPaths] self
      #
      # @since 0.1.2
      #
      # @see http://ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see Lotus::Utils::Kernel.Pathname
      def initialize(*paths)
        super(Array(paths))
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
      # @since 0.1.2
      def each(&blk)
        Utils::Kernel.Array(self).each do |path|
          blk.call Utils::Kernel.Pathname(path).realpath
        end
      end
    end
  end
end
