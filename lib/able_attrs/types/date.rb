module AbleAttrs
  module Types
    class Date < Base
      def import(value)
        case value
        when NilClass,::Date then value
        when ::String
          parse_string(value)
        end
      end

      private

      def parse_string(value)
        format = opt(:format)
        begin
          if format
            parse_with_format(value, format)
          else
            parse_no_format(value)
          end
        rescue ArgumentError
          nil
        end
      end

      def parse_no_format(value)
        ::Date.parse(value)
      end

      def parse_with_format(value, format)
        ::Date.strptime(value, format)
      end
    end
  end
end
