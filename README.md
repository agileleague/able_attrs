# AbleAttrs

Capable attributes for your Ruby classes. Provides a DSL to define attributes whose
values can be initialized, type-coerced, and transformed from common inputs upon setting.

While there are other "better-setter" gems out there, AbleAttrs
attempts to do more with less, minimize runtime dependencies (currently none),
and impose a very small API footprint on the classes that
implement it: `.able_attrs`, `._able_attr_definitions`, `#initialize`,
and `#apply_attrs`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'able_attrs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install able_attrs

## Usage

Currently, the system supports three built-in type-coercions
(`boolean`, `date`, and `integer`) which are accessible via the able_attrs definition DSL.

You may also use your own type-coersion by supplying it to the more generic
`attr` definition. The type that you supply must respond to `import` and
`default`.

All coersion/transformation occurs within the setter. The setter methods added can be overridden
and accessed via `super`

```ruby
class MyForm
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

response = MyForm.new({
  email: " Larry@example.com", login: "lazylarry", birthday: "1980-01-02",
  first_name: "Larry", last_name: "Friendly", number_of_cats: "3"
})

response.email
#=> "larry@example.com"

response.accepts_terms
#=> false

response.birthday
#=> #<Date: 1980-01-02 ((2444241j,0s,0n),+0s,2299161j)>

response.number_of_cats
#=> 3

response.apply_attrs("number_of_cats" => '-1')
response.number_of_cats
#=> 0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/agileleague/able_attrs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
