module AbleAttrs
  module Types
    class Boolean < Base
      attr_reader :true_values

      def initialize(options = {})
        super
        @true_values = opt(:true_values, self.class.default_true_values)
      end

      def import(value)
        true_values.include?(value)
      end

      def default
        false
      end

      def self.default_true_values
        [true, 'true', 1, '1']
      end
    end
  end
end
