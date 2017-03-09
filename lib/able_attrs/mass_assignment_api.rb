module AbleAttrs
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
end
