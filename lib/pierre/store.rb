require "json"
require "redis"
require "redis-namespace"
require "uri"
require "./lib/pierre/translation"

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

    def get(input_lang, key, options = { fallback: true })
      data, output_lang = fetch_data(input_lang, key, options[:fallback])

      Translation.new({
        lang: output_lang,
        key: key,
        text: data[:text],
        context: data[:context]
      })
    end

    def keys(lang)
      adapter.keys("#{ lang }:*").map do |raw_key|
        convert_raw_key(raw_key, lang)
      end.sort
    end

    def set(lang, key, text, options = {})
      lookup_key = "#{ lang }:#{ key }"
      data = {
        text: text,
        context: options[:context],
      }.to_json

      if adapter.set(lookup_key, data) == "OK"
        get(lang, key)
      end
    end

    private

    def build_adapter
      Redis::Namespace.new(namespace, redis: connection)
    end

    def connection
      Redis.new(
        host: parsed_uri.host,
        port: parsed_uri.port,
        password: parsed_uri.password,
      ).tap { |redis| redis.select(db) }
    end

    def convert_raw_key(key, lang)
      key.sub("#{ lang }:", "").to_sym
    end

    def default_fallback_lang
      :en
    end

    def dump_data_for(lang)
      keys = adapter.keys("#{ lang }:*")

      keys.each_with_object({}) do |raw_key, hash|
        converted_key = convert_raw_key(raw_key, lang)
        hash[converted_key] = get(lang, converted_key)
        hash
      end
    end

    def fetch_data(lang, key, fallback = true)
      lookup_key = "#{ lang }:#{ key }"
      data = adapter.get(lookup_key)

      if data.nil? || data.empty?
        unless lang == fallback_lang || !fallback
          fetch_data(fallback_lang, key, fallback)
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
  end
end
