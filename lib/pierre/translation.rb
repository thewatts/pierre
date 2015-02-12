module Pierre
  class Translation
    attr_reader   :attributes
    attr_accessor :context,
                  :fallback,
                  :fallback_text,
                  :key,
                  :lang,
                  :scope,
                  :text

    def initialize(attributes = {})
      @attributes    = attributes
      @lang          = attributes[:lang]
      @key           = attributes[:key]
      @text          = attributes[:text]
      @context       = attributes[:context]
      @fallback      = attributes[:fallback] || false
      @scope         = parse_scope(attributes[:scope])
      @fallback_text = attributes[:fallback_text] || "Missing Translation"

      after_initialize
    end

    def after_initialize
      parsed_key, parsed_scopes = parse_key(key)
      self.key   = parsed_key
      self.scope = scope + parsed_scopes
    end

    def fallback?
      fallback == true
    end

    def key
      symbol_for(@key)
    end

    def lang
      symbol_for(@lang)
    end

    def missing?
      text == fallback_text
    end

    def text
      unless @text.nil? || @text.empty?
        @text
      else
        fallback_text
      end
    end

    def to_json(options = {})
      {
        key: key,
        lang: lang,
        text: text,
        context: context,
        missing: missing?,
      }.to_json
    end

    private

    def parse_key(raw_key)
      keys  = raw_key.to_s.split(".").map(&:to_sym)
      key   = keys.pop
      [ key, keys ]
    end

    def parse_scope(scope)
      case scope
      when nil
        []
      when Array
        scope
      when String
        scope.split('.').map(&:to_sym)
      end
    end

    def symbol_for(value)
      if value
        value.to_sym
      end
    end
  end
end
