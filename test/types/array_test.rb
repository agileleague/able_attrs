require 'test_helper'

describe "AbleAttrs::Types::Array" do
  let(:type) { AbleAttrs::Types::Array.new }

  it "handles arrays" do
    assert_equal [], type.import([])
    assert_equal [1,'abc', nil], type.import([1, 'abc', nil])
  end

  it "handles strings" do
    assert_equal ['abc'], type.import('abc')
  end

  it "handles numbers" do
    assert_equal [123], type.import(123)
    assert_equal [123.001], type.import(123.001)
  end
end
