# frozen_string_literal: true

class WrappingHash
  def initialize(hash)
    @hash = hash.to_h
  end

  def to_hash
    @hash
  end
  alias_method :to_h, :to_hash
end
