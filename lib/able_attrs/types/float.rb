module AbleAttrs
  module Types
    class Float < Base
      def import(value)
        case value
        when NilClass,::Float then value
        when ::String, Numeric
          begin
            ::Kernel.Float(value)
          rescue ArgumentError
            nil
          end
        end
      end

      def default
        nil
      end
    end
  end
end
