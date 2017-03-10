require "able_attrs/definer"
require "able_attrs/definition"
require "able_attrs/mass_assignment_api"
require "able_attrs/processor"
require "able_attrs/version"
require "able_attrs/types"

module AbleAttrs
  def self.included(base)
    base.extend SupportMethods
    base.extend DSL
  end

  include MassAssignmentAPI

  module SupportMethods
    def _able_attr_definitions
      @_able_attr_definitions ||= {}
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
