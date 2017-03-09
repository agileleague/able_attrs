module AbleAttrs
  class Definition
    attr_reader :variable_name, :processor

    def initialize(field_name, processor)
      @variable_name = "@#{field_name}"
      @processor = processor
    end

    def set(instance, value)
      instance.instance_variable_set(variable_name, process_value(instance, value))
    end

    def get(instance)
      instance.instance_variable_get(variable_name)
    end

    def process_value(instance, value)
      processor.process(instance, value)
    end
  end
end
