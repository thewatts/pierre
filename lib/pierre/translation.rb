module Pierre
  class Translation
    attr_reader   :attributes
    attr_writer   :key, :lang
    attr_accessor :text, :context

    def initialize(attributes = {})
      @attributes = attributes
      @lang       = attributes[:lang]
      @key        = attributes[:key]
      @text       = attributes[:text]
      @context    = attributes[:context]
    end

    def lang
      symbol_for(@lang)
    end

    def key
      symbol_for(@key)
    end

    private

    def symbol_for(value)
      if value
        value.to_sym
      end
    end
  end
end
