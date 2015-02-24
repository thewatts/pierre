require "json"
require "redis"
require "redis-namespace"
require "uri"
require "pierre/translation"
require "pierre/store/options_sanitizer"

module Pierre
  class Store
    attr_reader :config, :db, :fallback_lang, :languages, :namespace, :uri

    def initialize(config = {})
      @config        = config
      @uri           = config[:uri]
      @db            = config[:db]
      @namespace     = config[:namespace]
      @fallback_lang = config[:fallback_lang] || default_fallback_lang
      @languages     = config[:languages] || []
    end

    def adapter
      @adapter ||= build_adapter
    end

    def dump(lang)
      dump_data_for(lang)
    end

    def flushdb
      adapter.flushdb
    end

    def get(input_lang, key, options = {})
      options = sanitize(options)
      data, output_lang  = fetch_data(input_lang, key, options)

      Translation.new({
        lang: output_lang,
        key: key,
        text: data[:text],
        context: data[:context],
        scope: options[:scope],
        fallback: input_lang != output_lang,
        fallback_text: options[:fallback_text]
      })
    end

    def keys(lang)
      adapter.keys("#{ lang }.*").map do |raw_key|
        convert_raw_key(raw_key, lang)
      end.sort
    end

    def manage(managing_lang, options = {})
      reference_lang = options[:reference] || :en
      reference_keys = keys(reference_lang)
      if managing_lang.to_sym == :all
        managing_langs = languages
      else
        managing_langs = [reference_lang, managing_lang]
      end

      reference_keys.each_with_object({}) do |key, hash|
        hash[key] = {}
        managing_langs.each do |lang|
          hash[key][lang] = get(lang, key, fallback: false)
        end
      end
    end

    def raw_keys
      adapter.keys
    end

    def remove(key)
      languages.each do |lang|
        lookup_key = build_key(lang, key)
        adapter.del(lookup_key)
      end
    end

    def set(lang, key, text, options = {})
      options = sanitize(options)

      lookup_key = build_key(lang, key, options[:scope])
      data = {
        text: text,
        context: options[:context],
      }.to_json

      if adapter.set(lookup_key, data) == "OK"
        get(lang, key, options)
      end
    end

    private

    def build_adapter
      Redis::Namespace.new(namespace, redis: connection)
    end

    def build_key(lang, key, scope_array = [])
      scoped_key = scope_array.dup.push(key).map(&:to_s).join(".")
      "#{ lang }.#{ scoped_key }"
    end

    def connection
      Redis.new(
        host: parsed_uri.host,
        port: parsed_uri.port,
        password: parsed_uri.password,
      ).tap { |redis| redis.select(db) }
    end

    def convert_raw_key(key, lang)
      key.sub("#{ lang }.", "").to_sym
    end

    def default_fallback_lang
      :en
    end

    def dump_data_for(lang)
      keys(lang).each_with_object({}) do |key, hash|
        hash[key] = get(lang, key).text
      end
    end

    def fetch_data(lang, key, options = {})
      options    = sanitize(options)
      lookup_key = build_key(lang, key, options[:scope])
      data       = parse_data(adapter.get(lookup_key))

      if needs_fallback?(data, lang, options)
        fetch_data(fallback_lang, key, options)
      else
        [ data, lang ]
      end
    end

    def parse_data(raw_data)
      raw_data ||= "{}"
      JSON.parse(raw_data, symbolize_names: true)
    end

    def parsed_uri
      URI.parse(uri)
    end

    def sanitize(options = {})
      OptionsSanitizer.sanitize(options)
    end

    def needs_fallback?(data, lang, options)
      options[:fallback] == true &&
      lang != fallback_lang      &&
      (data[:text].nil? || data[:text].empty?)
    end
  end
end
