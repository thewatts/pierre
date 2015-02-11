module Pierre
  class I18nAdapter
    attr_reader :store

    def initialize(store)
      @store = store
    end

    def [](raw_key)
      lang, key = parse_raw_key(raw_key)
      translation = store.get(lang, key)
      unless translation.missing?
        translation.text.to_json
      end
    end

    def []=(raw_key, value)
      lang, key = parse_raw_key(raw_key)
      store.set(lang, key, value)
    end

    def keys
      store.raw_keys.sort
    end

    private

    def parse_raw_key(raw_key)
      keys = raw_key.split(".")
      lang = keys.first
      key  = keys.last

      [ lang, key ]
    end
  end
end
