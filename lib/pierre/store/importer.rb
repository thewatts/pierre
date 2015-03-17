require 'csv'

module Pierre
  class Store
    class Importer
      attr_reader :file, :store

      def initialize(csv, store)
        @file  = csv
        @store = store
      end

      def headers
        rows.first.keys.sort
      end

      def import
        store.languages.each_with_object({}) do |lang, hash|
          hash[lang] = rows.map do |row|
            create_translation_from_lang_and_row(lang, row)
          end
        end
      end

      def keys
        rows.map { |row| row[:key] }.sort
      end

      private

      def create_translation_from_lang_and_row(lang, row)
        return if row[lang].nil?

        context = (lang.to_sym == :en) ? row[:context] : nil
        store.set(lang, row[:key], row[lang], context: context)
      end

      def data
        CSV.open(file, headers: true, header_converters: :symbol)
      end

      def rows
        @rows ||= data.map { |row| row.to_h }
      end
    end
  end
end
