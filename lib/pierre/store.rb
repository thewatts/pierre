require "json"
require "redis"
require "redis-namespace"
require "uri"

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

    def get(input_lang, key)
      data, output_lang = fetch_data(input_lang, key)

      unless data.nil? || data.empty?
        Translation.new({
          lang: output_lang,
          key: key,
          text: data[:text],
          context: data[:context]
        })
      end
    end

    def set(lang, key, text, options)
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

    def default_fallback_lang
      :en
    end

    def fetch_data(lang, key)
      lookup_key = "#{ lang }:#{ key }"
      data = adapter.get(lookup_key)

      if data.nil? || data.empty?
        unless lang == fallback_lang
          fetch_data(fallback_lang, key)
        end
      else
        parse_data_and_lang(data, lang)
      end
    end

    def parse_data_and_lang(raw_data, lang)
      [ JSON.parse(raw_data, symbolize_names: true), lang ]
    end

    def parsed_uri
      URI.parse(uri)
    end
  end
end
