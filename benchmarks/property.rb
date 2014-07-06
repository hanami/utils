$:.unshift 'lib'
require 'benchmark'
require 'lotus/utils/property'

TIMES = (ENV['TIMES'] || 1_000_000).to_i

class CollectionUsingProperty
  include Lotus::Utils::Property

  property(:identity) { @identity || :id }
end

class CollectionUsingMethod
  def identity(name = nil)
    if name
      @identity = name
    else
      @identity || :id
    end
  end
end

collection_property = CollectionUsingProperty.new
collection_method   = CollectionUsingMethod.new


Benchmark.bmbm(50) do |b|
  b.report '[WRITE] using Lotus::Utils::Property' do
    TIMES.times do
      collection_property.identity('custom_id')
    end
  end

  b.report '[READ] using Lotus::Utils::Property' do
    collection_property.identity('some_id')

    TIMES.times do
      collection_property.identity
    end
  end


  b.report '[WRITE] using Plain Old Ruby Method' do
    TIMES.times do
      collection_method.identity('custom_id')
    end
  end

  b.report '[READ] using Plain Old Ruby Method' do
    collection_property.identity('some_id')

    TIMES.times do
      collection_method.identity
    end
  end
end