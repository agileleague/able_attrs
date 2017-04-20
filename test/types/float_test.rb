require 'test_helper'

describe "AbleAttrs::Types::Float" do
  let(:type) { AbleAttrs::Types::Float.new() }

  it "converts strings" do
    result = type.import('83')
    assert_equal 83.0, result
    assert_instance_of Float, result
  end

  it "swallows exceptions on bad strings" do
    assert_nil type.import("83'")
  end

  it "converts Integers" do
    result = type.import('83')
    assert_equal 83.0, result
    assert_instance_of Float, result
  end

  it "handles nil" do
    assert_nil type.import(nil)
  end
end
