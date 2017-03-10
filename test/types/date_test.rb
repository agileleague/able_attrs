require 'test_helper'

describe "AbleAttrs::Types::Date" do
  it "parse a date normally with no arguments" do
    no_format_date_type = AbleAttrs::Types::Date.new()
    assert_equal Date.new(1900, 1, 2), no_format_date_type.import("1900-01-02")
    assert_nil no_format_date_type.import("1900000-0102")
  end

  it "allows specifying parsing format options" do
    formatted_date_type = AbleAttrs::Types::Date.new(format: "%m/%d/%Y")
    assert_equal Date.new(1900, 1, 2), formatted_date_type.import("01/02/1900")
    assert_nil formatted_date_type.import("1900000-0102")
  end
end
