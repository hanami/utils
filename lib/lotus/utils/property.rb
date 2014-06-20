module Lotus
  module Utils
    module Property
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def property(name, &blk)
          define_method name do |val = nil|
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
end
