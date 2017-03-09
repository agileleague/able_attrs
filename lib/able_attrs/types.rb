require "able_attrs/types/base"
require "able_attrs/types/any"
require "able_attrs/types/boolean"
require "able_attrs/types/date"
require "able_attrs/types/integer"

module AbleAttrs
  module Types
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
end

