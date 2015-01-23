module Pierre
  class Translation
    attr_reader   :attributes
    attr_writer   :key, :lang, :text
    attr_accessor :context, :fallback

    def initialize(attributes = {})
      @attributes = attributes
      @lang       = attributes[:lang]
      @key        = attributes[:key]
      @text       = attributes[:text]
      @context    = attributes[:context]
      @fallback   = attributes[:fallback]
    end

    def key
      symbol_for(@key)
    end

    def lang
      symbol_for(@lang)
    end

    def text
      unless @text.nil? || @text.empty?
        @text
      else
        fallback
      end
    end

    private

    def symbol_for(value)
      if value
        value.to_sym
      end
    end
  end
end
