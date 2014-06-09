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

      # It specifies the policy for initialize copies of the object, when #clone
      # or #dup are invoked.
      #
      # @api private
      # @since 0.2.0
      #
      # @see http://ruby-doc.org/core-2.1.2/Object.html#method-i-clone
      # @see http://ruby-doc.org/core-2.1.2/Object.html#method-i-dup
      #
      # @example
      #   require 'lotus/utils/load_paths'
      #
      #   paths  = Lotus::Utils::LoadPaths.new '.'
      #   paths2 = paths.dup
      #
      #   paths  << '..'
      #   paths2 << '../..'
      #
      #   paths
      #     # => #<Lotus::Utils::LoadPaths:0x007f84e0cad430 @paths=[".", ".."]>
      #
      #   paths2
      #     # => #<Lotus::Utils::LoadPaths:0x007faedc4ad3e0 @paths=[".", "../.."]>
      def initialize_copy(original)
        @paths = original.instance_variable_get(:@paths).dup
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
      # @raise [RuntimeError] if the object was previously frozen
      #
      # @since 0.2.0
      #
      # @see http://ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see Lotus::Utils::Kernel.Pathname
      # @see Lotus::Utils::LoadPaths#freeze
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

      # It freezes the object by preventing further modifications.
      #
      # @since 0.2.0
      #
      # @see http://ruby-doc.org/core-2.1.2/Object.html#method-i-freeze
      #
      # @example
      #   require 'lotus/utils/load_paths'
      #
      #   paths = Lotus::Utils::LoadPaths.new
      #   paths.freeze
      #
      #   paths.frozen?  # => true
      #
      #   paths.push '.' # => RuntimeError
      def freeze
        super
        @paths.freeze
      end
    end
  end
end
