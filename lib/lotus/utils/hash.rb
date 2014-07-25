module Lotus
  module Utils
    # Hash on steroids
    # @since 0.1.0
    class Hash
      # Initialize the hash
      #
      # @param hash [#to_h] the value we want to use to initialize this instance
      # @param blk [Proc] define the default value
      #
      # @return [Lotus::Utils::Hash] self
      #
      # @since 0.1.0
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-c-5B-5D
      #
      # @example Passing a Hash
      #   require 'lotus/utils/hash'
      #
      #   hash = Lotus::Utils::Hash.new('l' => 23)
      #   hash['l'] # => 23
      #
      # @example Passing a block for default
      #   require 'lotus/utils/hash'
      #
      #   hash = Lotus::Utils::Hash.new {|h,k| h[k] = [] }
      #   hash['foo'].push 'bar'
      #
      #   hash.to_h # => { 'foo' => ['bar'] }
      def initialize(hash = {}, &blk)
        @hash = hash.to_h
        @hash.default_proc = blk
      end

      # Convert in-place all the keys to Symbol instances, nested hashes are converted too.
      #
      # @return [Hash] self
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/utils/hash'
      #
      #   hash = Lotus::Utils::Hash.new 'a' => 23, 'b' => { 'c' => ['x','y','z'] }
      #   hash.symbolize!
      #
      #   hash.keys    # => [:a, :b]
      #   hash.inspect # => {:a=>23, :b=>{:c=>["x", "y", "z"]}}
      def symbolize!
        keys.each do |k|
          v = delete(k)
          v = Hash.new(v).symbolize! if v.is_a?(::Hash)

          self[k.to_sym] = v
        end

        self
      end

      # Returns a new array populated with the keys from this hash
      #
      # @return [Array] the keys
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-keys
      def keys
        @hash.keys
      end

      # Deletes the key-value pair and returns the value from hsh whose key is
      # equal to key.
      #
      # @param key [Object] the key to remove
      #
      # @return [Object,nil] the value hold by the given key, if present
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-keys
      def delete(key)
        @hash.delete(key)
      end

      # Retrieves the value object corresponding to the key object.
      #
      # @param key [Object] the key
      #
      # @return [Object,nil] the correspoding value, if present
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-5B-5D
      def [](key)
        @hash[key]
      end

      # Associates the value given by value with the key given by key.
      #
      # @param key [Object] the key to assign
      # @param value [Object] the value to assign
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-5B-5D-3D
      def []=(key, value)
        @hash[key] = value
      end

      # Returns a Ruby Hash as duplicated version of self
      #
      # @return [::Hash] the hash
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-to_h
      def to_h
        @hash.dup
      end

      alias_method :to_hash, :to_h

      # Converts into a nested array of [ key, value ] arrays.
      #
      # @return [::Array] the array
      #
      # @since x.x.x
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-to_a
      def to_a
        @hash.to_a
      end

      # Equality
      #
      # @return [TrueClass,FalseClass]
      #
      # @since x.x.x
      def ==(other)
        @hash == other.to_h
      end

      alias_method :eql?, :==

      # Returns the hash of the internal @hash
      #
      # @return [Fixnum]
      #
      # @since x.x.x
      def hash
        @hash.hash
      end

      # Override Ruby's method_missing in order to provide ::Hash interface
      #
      # @api private
      # @since x.x.x
      def method_missing(m, *args, &blk)
        h = @hash.__send__(m, *args, &blk)
        h = self.class.new(h) if h.is_a?(::Hash)
        h
      rescue NoMethodError
        raise NoMethodError.new(%(undefined method `#{ m }' for #{ @hash }:#{ self.class }))
      end
    end
  end
end
