module Lotus
  module Utils
    module Property
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def property(name, &blk)
          ivar_name        = "@#{name}"
          ivar_name_cached = "#{ivar_name}_cached"

          define_method name do |val = nil|
            if val
              instance_variable_set(ivar_name, val)
            else
              instance_variable_get(ivar_name_cached) || instance_variable_set(ivar_name_cached, instance_eval(&blk))
            end
          end
        end
      end
    end
  end
end
