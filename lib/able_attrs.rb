require "able_attrs/version"

module AbleAttrs
  def self.included(base)
    base.extend SupportMethods
    base.extend DSL
  end

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

  class Opts
    def initialize(hash)
      @hash = hash || {}
    end

    def [](key)
      return @hash[key] if @hash.has_key?(key)

      case key
      when Symbol
        @hash[key.to_s]
      when String
        @hash[key.to_sym]
      else
        nil
      end
    end
  end

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

    class Any < Base
      def import(value)
        value
      end
    end

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

    def self.named_types
      @named_types ||= TypeList.new({
        attr: Any,
        date: Date,
        integer: Integer,
        boolean: Boolean
      })
    end

    def self.replace!(type_name, type)
      named_types.replace!(type_name, type)
    end

    def self.valid_type?(type)
      type.respond_to?(:import) && type.respond_to?(:default)
    end
  end

  class TypeList
    def initialize(hash)
      @hash = hash
    end

    def [](type_name)
      type_name = type_name.to_sym
      ensure_type!(type_name)
      @hash[type_name]
    end

    def replace!(type_name, type)
      type_name = type_name.to_sym
      ensure_type!(type_name)
      @hash[type_name] = type
    end

    def copy
      self.class.new(@hash.clone)
    end

    private

    def ensure_type!(key)
      if !@hash.has_key?(key)
        raise ArgumentError, "unrecognized type: #{key}"
      end
    end
  end

  module MassAssignmentAPI
    def initialize(hash={})
      apply_attrs(hash, init: true)
    end

    def apply_attrs(hash, init: false)
      self.class._able_attr_definitions.each do |field_name, definition|
        value = if hash.has_key?(field_name)
                  hash[field_name]
                elsif hash.has_key?(field_name.to_s)
                  hash[field_name.to_s]
                else
                  next if !init
                  nil
                end

        send("#{field_name}=", value)
      end
    end
  end

  include MassAssignmentAPI

  module SupportMethods
    def _able_attr_definitions
      @_able_attr_definitions ||= {}
    end
  end

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

  module DSL
    def able_attrs &block
      raise ArgumentError, "block is required" unless block_given?
      definer = Definer.new(self)
      definer.instance_exec(definer, &block)
    end
  end
end
