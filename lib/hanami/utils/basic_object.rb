module Hanami
  module Utils
    # BasicObject
    #
    # @since 0.3.5
    class BasicObject
      # Interface for pp
      #
      # @param printer [PP] the Pretty Printable printer
      # @return [String] the pretty-printable inspection of the object
      #
      # @since 0.9.0
      #
      # @see https://ruby-doc.org/stdlib/libdoc/pp/rdoc/PP.html
      def pretty_print(printer)
        printer.text(inspect)
      end

      private

      # Must be overridden by descendants
      #
      # @since 0.3.5
      # @api private
      def respond_to_missing?(_method_name, _include_all)
        ::Kernel.raise ::NotImplementedError
      end
    end
  end
end
