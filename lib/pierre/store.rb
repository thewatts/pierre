require "json"
require "redis"
require "redis-namespace"
require "uri"
require "pierre/translation"
require "pierre/store/options_sanitizer"

module Pierre
  class Store
    attr_reader :config, :db, :fallback_lang, :namespace, :uri

    def initialize(config = {})
      @config        = config
      @uri           = config[:uri]
      @db            = config[:db]
      @namespace     = config[:namespace]
      @fallback_lang = config[:fallback_lang] || default_fallback_lang
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

      reference_keys.each_with_object({}) do |key, hash|
        hash[key] = {
          reference_lang => get(reference_lang, key),
          managing_lang  => get(managing_lang, key, fallback: false)
        }
      end
    end

    def raw_keys
      adapter.keys
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

    def build_key(lang, key, scope_array)
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
      data       = adapter.get(lookup_key)

      if data.nil? || data.empty?
        unless lang == fallback_lang || !options[:fallback]
          fetch_data(fallback_lang, key, options)
        else
          parse_data_and_lang(data, lang)
        end
      else
        parse_data_and_lang(data, lang)
      end
    end

    def parse_data_and_lang(raw_data, lang)
      raw_data ||= "{}"
      [ JSON.parse(raw_data, symbolize_names: true), lang ]
    end

    def parsed_uri
      URI.parse(uri)
    end

    def sanitize(options = {})
      OptionsSanitizer.sanitize(options)
    end
  end
end
