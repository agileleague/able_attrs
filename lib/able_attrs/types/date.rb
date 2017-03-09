module AbleAttrs
  module Types
    class Date < Base
      def import(value)
        case value
        when NilClass,::Date then value
        when String
          begin
            ::Date.parse(value)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
