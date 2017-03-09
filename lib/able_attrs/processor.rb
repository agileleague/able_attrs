module AbleAttrs
  class Processor
    attr_reader :type, :block, :default_arg

    def initialize(type:, block:, default:)
      @type = type
      @block = block
      @default_arg = default
    end

    def process(instance, value)
      value = default(instance) if value.nil?
      value = type.import(value)
      value = instance.instance_exec(value, &block) if block
      value
    end

    def default(instance)
      return type.default if default_arg == Unspecified

      case default_arg
      when Proc
        args = default_arg.arity == 0 ? [] : [instance]
        instance.instance_exec(*args, &default_arg)
      when NilClass, FalseClass, TrueClass, Numeric, Symbol
        default_arg
      else
        default_arg.clone
      end
    end
  end
end
