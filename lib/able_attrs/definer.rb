module AbleAttrs
  module Unspecified; end

  class Definer
    attr_reader :klass, :named_types
    private :klass, :named_types

    def initialize(klass)
      @klass = klass
      @named_types = Types.named_types.copy
    end

    def boolean(*field_names, default: Unspecified, opts: {}, &block)
      attr(*field_names, type: named_types[:boolean].new(opts), default: default, &block)
    end

    def date(*field_names, default: Unspecified, opts: {}, &block)
      attr(*field_names, type: named_types[:date].new(opts), default: default, &block)
    end

    def integer(*field_names, default: Unspecified, opts: {}, &block)
      attr(*field_names, type: named_types[:integer].new(opts), default: default, &block)
    end

    def attr(*field_names, type: nil, default: Unspecified, &block)
      field_names.each do |field_name|
        if !(field_name =~ (/\A[\w_][\d\w_]*\z/i))
          raise NameError, "invalid attribute name '#{field_name}'"
        end
        if klass._able_attr_definitions.has_key?(field_name.to_sym)
          raise NameError, "#{field_name} has already been defined"
        end
      end

      type ||= named_types[:attr].new
      enforce_valid_type!(type)

      processor = Processor.new(type: type, block: block, default: default)

      field_names.each do |field|
        klass._able_attr_definitions[field.to_sym] = Definition.new(field, processor)
      end

      method_strings = field_names.map do |field|
        <<-METHODS
          def #{field}
            self.class._able_attr_definitions[:#{field}].get(self)
          end

          def #{field}=(value)
            self.class._able_attr_definitions[:#{field}].set(self, value)
          end
        METHODS
      end

      attr_module = Module.new do
        class_eval(method_strings.join("\n"))
      end
      klass.include attr_module
    end

    def replace!(type_name, type)
      named_types.replace!(type_name, type)
    end

    private

    def enforce_valid_type!(type)
      if !Types.valid_type?(type)
        raise ArgumentError, 'custom type must implement "import" and "default" methods'
      end
    end
  end
end
