require 'test_helper'

describe AbleAttrs do
  it "works being included but not used" do
    my_class = Class.new do
      include AbleAttrs
    end

    i = my_class.new({})
  end

  it "supports integer attrs" do
    my_class = Class.new do
      include AbleAttrs

      able_attrs do
        integer :my_num
      end
    end

    i = my_class.new({my_num: '123'})
    assert_equal 123, i.my_num
    i.my_num = nil
    assert_nil i.my_num
    i.my_num = 123
    assert_equal 123, i.my_num
    i.my_num = false
    assert_nil i.my_num
  end

  it "supports date attrs" do
    my_class = Class.new do
      include AbleAttrs

      able_attrs do
        date :my_date
      end
    end

    i = my_class.new({my_date: "2010-01-02"})
    assert_equal Date.civil(2010,1,2), i.my_date
    i.my_date = nil
    assert_nil i.my_date
    i.my_date = ''
    assert_nil i.my_date
    i.my_date = 123
    assert_nil i.my_date
  end

  describe "booleans" do
    it "supports boolean attrs" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          boolean :my_bool
        end
      end

      i = my_class.new({my_bool: "1"})
      assert_equal true, i.my_bool
      i.my_bool = false
      assert_equal false, i.my_bool
      i.my_bool = true
      assert_equal true, i.my_bool
      i.my_bool = nil
      assert_equal false, i.my_bool

      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          boolean :my_bool, default: true
        end
      end

      i = my_class.new({})
      assert_equal true, i.my_bool
    end

    it "allows the selection of true values to be overriden" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          boolean :strict_bool, opts: {true_values: [true]}
          boolean :normal_bool
        end
      end

      i = my_class.new({})
      assert_equal false, i.strict_bool
      assert_equal false, i.normal_bool

      i.strict_bool = 'true'
      assert_equal false, i.strict_bool
      i.normal_bool = 'true'
      assert_equal true, i.normal_bool

      i.strict_bool = true
      assert_equal true, i.strict_bool
      i.normal_bool = true
      assert_equal true, i.normal_bool
    end
  end

  describe "blocks" do
    it "can be used to manipulate an arbitrary value" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          attr :my_reversed_string do |val|
            val.reverse
          end
        end
      end

      i = my_class.new my_reversed_string: "funky"
      assert_equal "yknuf", i.my_reversed_string
      i.my_reversed_string = "yucky"
      assert_equal "ykcuy", i.my_reversed_string
    end

    it "runs a block after it casts the value to the type" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          integer :num do |val|
            if val
              val + 2
            end
          end
        end
      end

      i = my_class.new
      i.num = '2'
      assert_equal 4, i.num
    end

    it "can 'return' a block with next" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          attr :str do |val|
            next 'abc'
            val
          end
        end
      end

      i = my_class.new string: 'sup'
      assert_equal 'abc', i.str
    end

    it "doesn't swallow block-related errors" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          attr :str do |value|
            value.reverse
          end
        end
      end
      i = my_class.new({str: '123'})
      assert_equal '321', i.str
      assert_raises NoMethodError do
        i.str = nil
      end
    end
  end

  describe "setters" do
    it "can be overridden and accessed via super" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          integer :num
        end

        def num=(value)
          value = value.reverse if value
          super(value)
        end
      end

      i = my_class.new
      i.num = '321'
      assert_equal 123, i.num
    end

    it "are used when doing mass-assignment" do
      my_class = Class.new do
        include AbleAttrs

        able_attrs do
          integer :num
        end

        def num=(value)
          value = value.reverse if value
          super(value)
        end
      end

      i = my_class.new num: '321'
      assert_equal 123, i.num
    end
  end

  it "supports defining attributes with the explicit-receiver block api" do
    my_class = Class.new do
      include AbleAttrs

      able_attrs do |a|
        a.boolean :accepts_tos, :wants_callback
        a.date :my_date, :my_other_date
        a.integer :age
        a.attr :cache
      end
    end
  end

  it "supports defining attributes with the implicit-receiver block api" do
    my_class = Class.new do
      include AbleAttrs

      able_attrs do |a|
        boolean :accepts_tos, :wants_callback
        date :my_date, :my_other_date
        integer :age
        attr :cache
      end
    end
  end

  it "supports block defaults that are called to supply blocks" do
    my_class = Class.new do
      include AbleAttrs

      able_attrs do
        date :start_date, :end_date, default: ->{ Date.today }
        integer :age, default: ->(o) { o.average_age }
        attr :country, default: proc { most_popular_country }
      end

      def average_age
        32
      end

      def most_popular_country
        "Uganda"
      end
    end
    i = my_class.new
    assert_equal Date.today, i.start_date
    assert_equal Date.today, i.end_date
    assert_equal 32, i.age
    assert_equal "Uganda", i.most_popular_country
  end

  it "clones default arguments that are strings, Arrays, and Hashes" do
    default_string = "John Doe"
    default_array = [1]
    default_hash = {a: 'b'}

    my_class = Class.new do
      include AbleAttrs

      able_attrs do
        attr :name, default: default_string
        attr :array, default: default_array
        attr :hash, default: default_hash
      end
    end

    i = my_class.new
    assert_equal default_string, i.name
    refute_equal default_string.object_id, i.name.object_id

    assert_equal default_array, i.array
    refute_equal default_array.object_id, i.array.object_id

    assert_equal default_hash, i.hash
    refute_equal default_hash.object_id, i.hash.object_id
  end

  it "allows you to replace the built-in types able_attr definition" do
    integer_doubler = Class.new do
      def initialize(hash)
      end

      def import(value)
        value.to_i * 2
      end

      def default
        7
      end
    end

    my_class = Class.new do
      include AbleAttrs

      able_attrs do
        replace! :integer, integer_doubler
        integer :age
      end
    end

    i = my_class.new(age: '32')
    assert_equal 64, i.age

    my_standard_integer_class = Class.new do
      include AbleAttrs

      able_attrs do
        integer :age
      end
    end

    i = my_standard_integer_class.new(age: '32')
    assert_equal 32, i.age
  end

  it "evaluates: default, type, block" do
    my_class = Class.new do
      include AbleAttrs
      my_doubler_type = Module.new do
        def self.import(value)
          value * 2
        end

        def self.default
          32
        end
      end

      able_attrs do
        attr :age, type: my_doubler_type do |val|
          val * 3
        end
      end
    end

    i = my_class.new({})
    assert_equal 192, i.age
    i.age = 21
    assert_equal 126, i.age
  end

  it "works with the README example" do
    my_form = Class.new do
      include AbleAttrs

      sanitized_string = Module.new do
        def self.import(value)
          value.to_s.strip.downcase
        end

        def self.default
          ''
        end
      end

      able_attrs do
        boolean :accepts_terms
        date :birthday
        attr :first_name, :last_name
        attr :email, :login, type: sanitized_string
        integer :number_of_cats
      end

      def number_of_cats=(value)
        super
        if number_of_cats.to_i < 0
          super(0)
        end
      end
    end

    response = my_form.new({
      email: " Larry@example.com", login: "lazylarry", birthday: "1980-01-02",
      first_name: "Larry", last_name: "Friendly", number_of_cats: "3"
    })

    assert_equal "larry@example.com", response.email
    assert_equal 3, response.number_of_cats
    assert_equal false, response.accepts_terms
    assert_equal Date.civil(1980,1,2), response.birthday

    response.apply_attrs("number_of_cats" => '-1')
    assert_equal 0, response.number_of_cats
  end
end
