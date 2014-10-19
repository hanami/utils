# #!/usr/bin/env ruby -W0
# load File.dirname(__FILE__) + '/utils.rb'
$:.unshift 'lib'

require "lotus/utils/string"
require "benchmark/ips"
require "allocation_stats"

      # #   string = Lotus::Utils::String.new 'LotusUtils'
      # #   string.underscore # => 'lotus_utils'
      # def underscore
      #   self.class.new gsub(NAMESPACE_SEPARATOR, '/').
      #     gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
      #     gsub(/([a-z\d])([A-Z])/,'\1_\2').
      #     downcase
      # end

UNDERSCORE_TARGET_SEPARATOR = "/".freeze
UNDERSCORE_DIVISION_TARGET  = '\1_\2'.freeze

class Lotus::Utils::String
  def underscore_v2
    self.class.new gsub(NAMESPACE_SEPARATOR, UNDERSCORE_TARGET_SEPARATOR).
      gsub(/([A-Z\d]+)([A-Z][a-z])/, UNDERSCORE_DIVISION_TARGET).
      gsub(/([a-z\d])([A-Z])/, UNDERSCORE_DIVISION_TARGET).
      downcase
  end

  def underscore_v3
    new_string = gsub(NAMESPACE_SEPARATOR, UNDERSCORE_TARGET_SEPARATOR)
    new_string.gsub!(/([A-Z\d]+)([A-Z][a-z])/, UNDERSCORE_DIVISION_TARGET)
    new_string.gsub!(/([a-z\d])([A-Z])/, UNDERSCORE_DIVISION_TARGET)
    new_string.downcase!
    self.class.new new_string
  end
end

p "Benchmarking speed"
string = Lotus::Utils::String.new 'LotusUtils'
other  = Lotus::Utils::String.new 'APIDoc'
Benchmark.ips do |x|
  x.report "slow" do
    string.underscore
    other.underscore
  end

  x.report "v2" do
    string.underscore_v2
    other.underscore_v2
  end

  x.report "v3" do
    string.underscore_v3
    other.underscore_v3
  end
end

p "benchmarking allocations"

string = Lotus::Utils::String.new 'LotusUtils'
other  = Lotus::Utils::String.new 'APIDoc'
stats = AllocationStats.trace do
  1000.times do
    string.underscore
    other.underscore
  end
end
puts "Allocations for old:"
puts stats.allocations(alias_paths: true).group_by(:sourcefile, :sourceline, :class).to_text

string = Lotus::Utils::String.new 'LotusUtils'
other  = Lotus::Utils::String.new 'APIDoc'
stats = AllocationStats.trace do
  1000.times do
    string.underscore_v2
    other.underscore_v2
  end
end
puts "Allocations for v2:"
puts stats.allocations(alias_paths: true).group_by(:sourcefile, :sourceline, :class).to_text

string = Lotus::Utils::String.new 'LotusUtils'
other  = Lotus::Utils::String.new 'APIDoc'
stats = AllocationStats.trace do
  1000.times do
    string.underscore_v3
    other.underscore_v3
  end
end
puts "Allocations for v3:"
puts stats.allocations(alias_paths: true).group_by(:sourcefile, :sourceline, :class).to_text
