module Pierre
  class Store
    class OptionsSanitizer
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def context
        options[:context]
      end

      def fallback
        if options[:fallback] == false
          false
        else
          true
        end
      end

      def fallback_text
        options[:fallback_text]
      end

      def scope
        case options[:scope]
        when String
          options[:scope].split(".").map(&:to_sym)
        when Array
          options[:scope]
        else
          []
        end
      end

      def to_hash
        {
          fallback: fallback,
          fallback_text: fallback_text,
          scope: scope,
          context: context,
        }
      end

      def self.sanitize(options = {})
        new(options).to_hash
      end
    end
  end
end
