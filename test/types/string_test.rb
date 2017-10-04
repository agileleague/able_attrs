require 'test_helper'

describe "AbleAttrs::Types::String" do
  let(:type) { AbleAttrs::Types::String.new() }

  it "converts strings" do
    result = type.import('abc')
    assert_equal 'abc', result
  end

  it "handles nil" do
    result = type.import(nil)
    assert_nil result
  end

  it "converts integers" do
    result = type.import(123)
    assert_equal '123', result
  end

  it "converts floats" do
    result = type.import(123.1299)
    assert_equal '123.1299', result
  end

  it "converts symbols" do
    result = type.import(:active)
    assert_equal 'active', result
  end

  it "optionally trims string input" do
    test_string = " a hearty hello\n "
    result = AbleAttrs::Types::String.new(strip: true).import(test_string)
    assert_equal 'a hearty hello', result

    result = AbleAttrs::Types::String.new(strip: false).import(test_string)
    assert_equal " a hearty hello\n ", result

    result = AbleAttrs::Types::String.new().import(test_string)
    assert_equal " a hearty hello\n ", result
  end
end
