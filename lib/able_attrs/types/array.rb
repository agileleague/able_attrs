module AbleAttrs
  module Types
    class Array < Base
      def import(value)
        return nil if value.nil?
        case value
        when ::Array then value.dup
        else
          [value]
        end
      end

      def default
        []
      end
    end
  end
end
