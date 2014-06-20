module Lotus
  def self.property(name, &blk)
    Lotus::Utils::Property.new(name, &blk)
  end
end

module Lotus  
  module Utils    
    class Property < Module
      def initialize(name, &blk)
        @name, @blk = name, blk
      end
      
      def included(base)
        super
        define_property(@name, &@blk)
      end
      
      private
      
      def define_property(name, &blk)
        define_method(name) do |val = nil|
          if val
            instance_variable_set("@#{name}", val)
          else
            instance_eval &blk
          end
        end
      end
    end    
  end
end
