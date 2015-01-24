# Pierre
A gem for adding Multi Language Management to your application

### Named after Pierre-François Bouchard
> [Pierre-François Bouchard was an officer in the French Army engineers who is most famous for discovering the Rosetta Stone](http://en.wikipedia.org/wiki/Pierre-Fran%C3%A7ois_Bouchard)

![Mr. Bouchard](http://artinvestment.ru/content/download/news/20091016_jean_francois_champollion.jpg)

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pierre'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pierre

## Setup (Rails)

Within an initialization file, you'll need to:

```ruby
## config/initializers/pierre.rb

# 1. Setup a new `Pierre::Store`
redis_uri     = "redis://127.0.0.1:6379"
db_index      = 0
namespace     = :my_project
lang = :fr

store = Pierre::Store.new({
  uri: redis_uri,        # the URI of the Redis service being used
  db:  db_index,         # the index of the database in Redis
  namespace: namespace,  # the namepace desired for the Redis database
  fallback_lang: lang,   # OPTIONAL: Set the fallback language if a translation is missing (defaults to :en)
})

# 2. Assign that `store` to `Pierre`
Pierre.configure do |config|
  config.store = store
end
```

## Usage

### Adding a Translation

In order to add the translation for a word, your format will look like:
```ruby
Pierre.set(language, key, text, options)
# => <Pierre::Translation ... >
```

- `language`: the language you are adding this translation for, example: `:en` or `:fr`
    - Ultimately, it could be anything, so long as it's a symbol
- `key`: this is the key to identify the piece of translated text, also a symbol. Example: `:welcome_message`
- `text`: the text associated with the translation, ex: "Hello World" for `:en`, or "Hola Mundo" for `:es`, etc
- `options`: These are optional, and currently - only `context` is supported.
    - Example: ```options = { context: "A welcome message for the masses!" }```

### Retrieving a Translation

```ruby
Pierre.get(language, key)
# => <Pierre::Translation ... >
```

### A Translation Object

When setting / getting translations, a `Pierre::Translation` object is returned.

```ruby
options = { context: "A welcome message for the masses!" })
translation = Pierre.set(:en, :welcome_message, "Hello World", options)

translation.lang
# => :en
translation.key
# => :welcome_message
translation.text
# => "Hello World"
translation.context
# => "A welcome message for the masses!"

# NOTE: an identical object would be retrived via Pierre.get(:en, :welcome_message)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pierre/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
