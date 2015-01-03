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

      # Convert in-place all the keys to Symbol instances, nested hashes are converted too.
      #
      # @return [Hash] self
      #
      # @since 0.3.2
      #
      # @example
      #   require 'lotus/utils/hash'
      #
      #   hash = Lotus::Utils::Hash.new a: 23, b: { c: ['x','y','z'] }
      #   hash.stringify!
      #
      #   hash.keys    # => [:a, :b]
      #   hash.inspect # => {"a"=>23, "b"=>{"c"=>["x", "y", "z"]}}
      def stringify!
        keys.each do |k|
          v = delete(k)
          v = Hash.new(v).stringify! if v.is_a?(::Hash)

          self[k.to_s] = v
        end

        self
      end

      # Return a deep copy of the current Lotus::Utils::Hash
      #
      # @return [Hash] a deep duplicated self
      #
      # @since 0.3.1
      #
      # @example
      #   require 'lotus/utils/hash'
      #
      #   hash = Lotus::Utils::Hash.new(
      #     'nil'        => nil,
      #     'false'      => false,
      #     'true'       => true,
      #     'symbol'     => :foo,
      #     'fixnum'     => 23,
      #     'bignum'     => 13289301283 ** 2,
      #     'float'      => 1.0,
      #     'complex'    => Complex(0.3),
      #     'bigdecimal' => BigDecimal.new('12.0001'),
      #     'rational'   => Rational(0.3),
      #     'string'     => 'foo bar',
      #     'hash'       => { a: 1, b: 'two', c: :three },
      #     'u_hash'     => Lotus::Utils::Hash.new({ a: 1, b: 'two', c: :three })
      #   )
      #
      #   duped = hash.deep_dup
      #
      #   hash.class  # => Lotus::Utils::Hash
      #   duped.class # => Lotus::Utils::Hash
      #
      #   hash.object_id  # => 70147385937100
      #   duped.object_id # => 70147385950620
      #
      #   # unduplicated values
      #   duped['nil']        # => nil
      #   duped['false']      # => false
      #   duped['true']       # => true
      #   duped['symbol']     # => :foo
      #   duped['fixnum']     # => 23
      #   duped['bignum']     # => 176605528590345446089
      #   duped['float']      # => 1.0
      #   duped['complex']    # => (0.3+0i)
      #   duped['bigdecimal'] # => #<BigDecimal:7f9ffe6e2fd0,'0.120001E2',18(18)>
      #   duped['rational']   # => 5404319552844595/18014398509481984)
      #
      #   # it duplicates values
      #   duped['string'].reverse!
      #   duped['string'] # => "rab oof"
      #   hash['string']  # => "foo bar"
      #
      #   # it deeply duplicates Hash, by preserving the class
      #   duped['hash'].class # => Hash
      #   duped['hash'].delete(:a)
      #   hash['hash'][:a]    # => 1
      #
      #   duped['hash'][:b].upcase!
      #   duped['hash'][:b] # => "TWO"
      #   hash['hash'][:b]  # => "two"
      #
      #   # it deeply duplicates Lotus::Utils::Hash, by preserving the class
      #   duped['u_hash'].class # => Lotus::Utils::Hash
      def deep_dup
        Hash.new.tap do |result|
          @hash.each {|k, v| result[k] = duplicate(v) }
        end
      end

      # Returns a new array populated with the keys from this hash
      #
      # @return [Array] the keys
      #
      # @since 0.3.0
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
      # @since 0.3.0
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
      # @since 0.3.0
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
      # @since 0.3.0
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-5B-5D-3D
      def []=(key, value)
        @hash[key] = value
      end

      # Returns a Ruby Hash as duplicated version of self
      #
      # @return [::Hash] the hash
      #
      # @since 0.3.0
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-to_h
      def to_h
        @hash.each_with_object({}) do |(k, v), result|
          v = v.to_h if v.is_a?(self.class)
          result[k] = v
        end
      end

      alias_method :to_hash, :to_h

      # Converts into a nested array of [ key, value ] arrays.
      #
      # @return [::Array] the array
      #
      # @since 0.3.0
      #
      # @see http://www.ruby-doc.org/core/Hash.html#method-i-to_a
      def to_a
        @hash.to_a
      end

      # Equality
      #
      # @return [TrueClass,FalseClass]
      #
      # @since 0.3.0
      def ==(other)
        @hash == other.to_h
      end

      alias_method :eql?, :==

      # Returns the hash of the internal @hash
      #
      # @return [Fixnum]
      #
      # @since 0.3.0
      def hash
        @hash.hash
      end

      # Returns a string describing the internal @hash
      #
      # @return [String]
      #
      # @since 0.3.0
      def inspect
        @hash.inspect
      end

      # Override Ruby's method_missing in order to provide ::Hash interface
      #
      # @api private
      # @since 0.3.0
      #
      # @raise [NoMethodError] If doesn't respond to the given method
      def method_missing(m, *args, &blk)
        if respond_to?(m)
          h = @hash.__send__(m, *args, &blk)
          h = self.class.new(h) if h.is_a?(::Hash)
          h
        else
          raise NoMethodError.new(%(undefined method `#{ m }' for #{ @hash }:#{ self.class }))
        end
      end

      # Override Ruby's respond_to_missing? in order to support ::Hash interface
      #
      # @api private
      # @since 0.3.0
      def respond_to_missing?(m, include_private=false)
        @hash.respond_to?(m, include_private)
      end

      private
      # @api private
      # @since 0.3.1
      def duplicate(value)
        case value
        when NilClass, FalseClass, TrueClass, Symbol, Numeric
          value
        when Hash
          value.deep_dup
        when ::Hash
          Hash.new(value).deep_dup.to_h
        else
          value.dup
        end
      end
    end
  end
end
