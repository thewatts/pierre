require "spec_helper"

module Pierre
  describe Importer do
    let(:store)    { Pierre::Store.new(languages: [:en, :es]) }
    let(:csv)      { File.open("./spec/support/files/example-csv.csv") }
    let(:importer) { Importer.new(csv, store) }

    describe "#initialize" do
      it "initializes with an instance of the store" do
        expect(importer.store).to eq store
      end

      it "initializes the csv file" do
        expect(importer.file).to eq csv
      end
    end

    describe "#headers" do
      it "pulls the headers from the csv file" do
        expect(importer.headers).to eq [:en, :es, :context, :key].sort
      end
    end

    describe "#keys" do
      it "pulls the keys from the csv file" do
        expect(importer.keys).to eq ["hello", "goodbye"].sort
      end
    end

    describe "#import" do

      it "imports the CSV and correctly injects the translations" do
        expect(store).to receive(:set)
          .with(:en, "hello", "Hello!", context: "A welcome message")
          .and_return("Translation: Hello English")
        expect(store).to receive(:set)
          .with(:es, "hello", "Hola!", context: nil)
          .and_return("Translation: Hello Spanish")
        expect(store).to receive(:set)
          .with(:en, "goodbye", "Cheers!", context: "A farewell message")
          .and_return("Translation: Goodbye English")
        expect(store).to receive(:set)
          .with(:es, "goodbye", "Adios!", context: nil)
          .and_return("Translation: Goodbye Spanish")

        results = importer.import

        expect(results).to eq ({
          en: [
            "Translation: Hello English",
            "Translation: Goodbye English",
          ],
          es: [
            "Translation: Hello Spanish",
            "Translation: Goodbye Spanish",
          ]
        })
      end
    end
  end
end
