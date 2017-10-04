module AbleAttrs
  module Types
    class String < Base
      def import(value)
        coerced_value = case value
                        when ::String then value.dup
                        when NilClass then value
                        when Boolean,::Numeric,::Symbol then value.to_s
                        else
                          nil
                        end
        if opt(:strip, false) && coerced_value.respond_to?(:strip)
          coerced_value.strip
        else
          coerced_value
        end
      end

      def default
        ''
      end
    end
  end
end
