require "spec_helper"

module Pierre
  describe Store do
    let(:config) {
      {
        db: TEST_DB,
        namespace: TEST_NAMESPACE,
        uri: TEST_URI,
      }
    }

    let(:store) { Store.new(config) }

    before { store.adapter.flushdb }

    describe "#config" do
      it "can be assigned" do
        expect(store.config).to eq config
      end
    end

    describe "#adapter" do
      it "is an instance of Redis::Namespace" do
        expect(store.adapter).to be_kind_of Redis::Namespace
      end
    end

    describe "#set" do
      let(:lang) { :en }
      let(:key)  { :welcome_message }
      let(:text) { "Hello World" }
      let(:context) { "A Welcome message to the masses." }
      let(:options) { { context: context } }

      it "sets the translation values in Redis" do
        store.set(lang, key, text, options)

        expected_data = { text: text, context: context }.to_json
        lookup_key = "#{ lang }:#{ key }"

        stored_data = store.adapter.get(lookup_key)
        expect(stored_data).to eq expected_data
      end

      it "returns a Translation instance after setting" do
        result = store.set(lang, key, text, options)

        expect(result).to be_kind_of Pierre::Translation
        expect(result.lang).to    eq lang
        expect(result.key).to     eq key
        expect(result.text).to    eq text
        expect(result.context).to eq context
      end
    end

    describe "#get" do
      let(:lang)       { :en }
      let(:key)        { :welcome_message }
      let(:text)       { "Hello World" }
      let(:context)    { "A Welcome message to the masses." }
      let(:lookup_key) { "#{ lang }:#{ key }" }
      let(:data) {
        {
          text: text,
          context: context,
        }.to_json
      }

      before { store.adapter.set(lookup_key, data) }

      it "returns a Translation instance of the data" do
        result = store.get(lang, key)

        expect(result).to be_kind_of Pierre::Translation
        expect(result.lang).to    eq lang
        expect(result.key).to     eq key
        expect(result.text).to    eq text
        expect(result.context).to eq context
      end

      it "returns the translation for the fallback language if not set" do
        french = :fr
        result = store.get(french, key)

        expect(result).to be_kind_of Pierre::Translation
        expect(result.lang).to    eq :en
        expect(result.key).to     eq key
        expect(result.text).to    eq text
        expect(result.context).to eq context
      end

      it "returns nil if there is no data for lang or fallback lang" do
        store.adapter.flushdb # ensure no data is stored
        result = store.get(:fr, key)
        expect(result).to be_nil
      end
    end
  end
end
