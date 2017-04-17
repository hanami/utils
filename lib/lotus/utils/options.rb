require 'lotus/utils/hash'

module Lotus
  module Utils
    # This class provides methods for options.
    #
    # @since x.x.x
    class Options < Lotus::Utils::Hash
      # Check options on included key or keys
      #
      # @param keys [Symbol] the specific key or keys.
      #
      # @return [NilClass] if options contain a keys.
      #
      # @raise [ArgumentError] if options not contain a keys.
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/utils/class'
      #
      #   options = Lotus::Utils::Options.new(foo: :bar)
      #
      #   options.check_keys(:foo) # => nil
      #   options.check_keys(:foo, :baz) # => raises ArgumentError
      def check_options!(*keys)
        keys.each do |key|
          raise ArgumentError.new("missing keyword: #{key}") unless self.keys.include?(key)
        end
      end
    end
  end
end
