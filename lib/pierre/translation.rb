module Pierre
  class Translation
    attr_reader   :attributes
    attr_writer   :key, :lang, :text
    attr_accessor :context, :fallback_text

    def initialize(attributes = {})
      @attributes    = attributes
      @lang          = attributes[:lang]
      @key           = attributes[:key]
      @text          = attributes[:text]
      @context       = attributes[:context]
      @fallback_text = attributes[:fallback_text] || "Missing Translation"
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
      }.to_json
    end

    private

    def symbol_for(value)
      if value
        value.to_sym
      end
    end
  end
end
