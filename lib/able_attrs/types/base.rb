module AbleAttrs
  module Types
    class Base
      attr_reader :opts

      def initialize(options={})
        @opts = Opts.new(options)
      end

      def default
        nil
      end

      private

      def opt(name, default=nil)
        result = opts[name]
        return result unless result.nil?
        default
      end
    end
  end
end
