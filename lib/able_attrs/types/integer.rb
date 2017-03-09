module AbleAttrs
  module Types
    class Integer < Base
      def import(value)
        case value
        when NilClass,::Integer then value
        when String
          begin
            ::Kernel.Integer(value, 10)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
