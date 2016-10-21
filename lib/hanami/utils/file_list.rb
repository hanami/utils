module Hanami
  module Utils
    # Ordered file list, consistent across operating systems
    #
    # @since x.x.x
    module FileList
      # Return an ordered list of files, consistent across operating systems
      #
      # It has the same signature of <tt>Dir.glob</tt>, it just guarantees to
      # order the results before to return them.
      #
      # @since x.x.x
      #
      # @see https://ruby-doc.org/core/Dir.html#method-c-glob
      def self.[](*args)
        Dir.glob(*args).sort!
      end
    end
  end
end
