require "spec_helper"

module Pierre
  describe I18nAdapter do
    let(:adapter) { Pierre::I18nAdapter.new(store) }

    describe "#initialize" do
      it "initializes with a Pierre::Store" do
        expect(adapter.store).to eq store
      end
    end

    describe "#[](key)" do
      before do
        store.flushdb
        store.set(:en, :hello, "World")
      end

      it "gets the translation for the key from the store" do
        expect(adapter["en.hello"]).to eq "World"
      end
    end

    describe "#[]=(key)" do
      before { store.flushdb }

      it "adds the translation for a key to the store" do
        adapter["en.goodbye"] = "Cheers"
        expect(store.get(:en, :goodbye).text).to eq "Cheers"
      end
    end

    describe "#keys" do
      before { store.flushdb }

      it "pulls all the raw keys from the store" do
        expected = ["en.hello", "es.hello", "en.goodbye"].sort
        store.set(:en, :hello,   "Hiya!")
        store.set(:en, :goodbye, "BYE!")
        store.set(:es, :hello,   "Hola!")

        results = adapter.keys
        expect(results).to eq expected
      end
    end

    def store
      @store ||= Pierre::Store.new(
        uri: TEST_URI,
        db: TEST_DB,
        namespace: TEST_NAMESPACE,
      )
    end
  end
end
