require "spec_helper"
require "./lib/pierre/store"

module Pierre
  describe Store do
    let(:config) {
      {
        db: TEST_DB,
        languages: [:en, :es, :fr],
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

    describe "#languages" do
      context "without anything set" do
        it "returns an empty array" do
          expect(Store.new.languages).to eq []
        end
      end

      context "when store is initialized with languages" do
        it "returns the initialized languages" do
          expect(store.languages).to eq [:en, :es, :fr]
        end
      end
    end


    describe "#set" do
      let(:lang)    { :en }
      let(:key)     { :welcome_message }
      let(:text)    { "Hello World" }
      let(:context) { "A Welcome message to the masses." }
      let(:options) { { context: context } }

      it "sets the translation values in Redis" do
        store.set(lang, key, text, options)

        expected_data = { text: text, context: context }.to_json
        lookup_key = "#{ lang }.#{ key }"

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

      context "with added scope" do
        it "sets the translation value in redis based on scope" do
          options[:scope] = [ :down, :more, :levels ]
          store.set(lang, key, text, options)

          expected_data = { text: text, context: context }.to_json
          stored_data = store.adapter.get("en.down.more.levels.welcome_message")

          expect(stored_data).to eq expected_data
        end
      end

      context "with added scope via the initial key" do
        it "sets the translation value in redis based on scope" do
          key = "down.more.levels.welcome_message"
          store.set(lang, key, text, options)

          expected_data = { text: text, context: context }.to_json
          stored_data = store.adapter.get("en.down.more.levels.welcome_message")

          expect(stored_data).to eq expected_data
        end
      end
    end

    describe "#get" do
      let(:lang)       { :en }
      let(:key)        { :welcome_message }
      let(:text)       { "Hello World" }
      let(:context)    { "A Welcome message to the masses." }
      let(:lookup_key) { "#{ lang }.#{ key }" }
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
        expect(result.missing?).to  be false
        expect(result.fallback?).to be false
        expect(result.lang).to      eq lang
        expect(result.key).to       eq key
        expect(result.text).to      eq text
        expect(result.context).to   eq context
      end

      context "when missing a translation" do
        context "when fallback is enabled (the default)" do
          it "returns the translation for the fallback language if not set" do
            french = :fr
            result = store.get(french, key)

            expect(result).to be_kind_of Pierre::Translation
            expect(result.missing?).to  be false
            expect(result.fallback?).to be true
            expect(result.lang).to      eq :en
            expect(result.key).to       eq key
            expect(result.text).to      eq text
            expect(result.context).to   eq context
          end

          context "when the translation is an empty string" do
            before { store.set(:fr, key, "") }

            it "returns the translation for the fallback language" do
              result = store.get(:fr, key)

              expect(result).to be_kind_of Pierre::Translation
              expect(result.lang).to      eq :en
              expect(result.missing?).to  be false
              expect(result.fallback?).to be true
              expect(result.key).to       eq key
              expect(result.text).to      eq text
              expect(result.context).to   eq context
            end
          end
        end

        context "when fallback is disabled (set to false)" do
          it "returns a Translation object if there is no translation" do
            store.adapter.flushdb # ensure no data is stored
            store.set(lang, key, text)
            result = store.get(:fr, key, fallback: false)

            expect(result).to be_kind_of Pierre::Translation
            expect(result.missing?).to  be true
            expect(result.fallback?).to be false
            expect(result.lang).to      eq :fr
            expect(result.key).to       eq key
            expect(result.text).to      eq "Missing Translation"
            expect(result.context).to   eq nil
          end
        end
      end
    end

    describe "#keys" do
      it "returns the sorted keys for the given language" do
        store.set(:en, :boom, "hello")
        store.set(:en, :shaka, "world")
        store.set(:en, :laka,  "!!!")

        expect(store.keys(:en)).to eq [:boom, :laka, :shaka]
      end
    end

    describe "#dump" do
      it "returns the data (keys, translations) for the given language" do
        store.set(:en, :boom, "hello")
        store.set(:en, :shaka, "world")
        store.set(:en, :laka,  "!!!")

        dump = store.dump(:en)

        expect(dump.keys).to eq [:boom, :laka, :shaka]
        expect(dump.values).to eq ["hello", "!!!", "world"]
      end

      it "does not return items that are missing translations" do
        store.set(:en, :boom, "hello")
        store.set(:en, :shaka, "world")
        store.set(:es, :boom, "hola")
        store.set(:es, :shaka, "")

        dump = store.dump(:es)
        expect(dump.keys).to eq [:boom]
        expect(dump.values).to eq ["hola"]
      end
    end

    describe "#manage" do
      it "returns the state of the given language, in comparison to the reference language" do
        store.set(:en, :boom, "hello")
        store.set(:en, :shaka, "world")
        store.set(:es, :boom, "hola")

        data = store.manage(:es, reference: :en) # :en is the default

        expect(data.keys).to eq [:boom, :shaka]

        expect(data[:boom].keys).to eq [:en, :es]
        expect(data[:boom].values.map(&:text)).to eq ["hello", "hola"]
        expect(data[:boom].values.map(&:missing?)).to eq [false, false]

        expect(data[:shaka].keys).to eq [:en, :es]
        expect(data[:shaka].values.map(&:text)).to eq ["world", "Missing Translation"]
        expect(data[:shaka].values.map(&:missing?)).to eq [false, true]
      end

      it "only includes keys that are specified in the reference language" do
        store.set(:en, :boom, "hello")
        store.set(:es, :boom, "hola")
        store.set(:en, :shaka, "shaka")
        store.set(:es, :other, "not specified in english")

        data = store.manage(:es, reference: :en)

        expect(data.keys).to eq [:boom, :shaka]
      end

      it "returns all languages if first argument is :all" do
        store.set(:en, :boom, "hello")
        store.set(:es, :boom, "hola")
        store.set(:fr, :boom, "bonjour")
        store.set(:en, :shaka, "shaka")
        store.set(:fr, :frenchy, "frenchy")

        data = store.manage(:all)

        expect(data.keys).to eq [:boom, :shaka]
        expect(data[:boom].keys).to eq [:en, :es, :fr]
      end
    end

    describe "#remove" do
      before do
        store.set(:en, :boom, "hello")
        store.set(:es, :boom, "hola")
      end

      it "removes translations for all languages of a specific key" do
        store.remove(:boom)

        expect(store.adapter.get("en.boom")).to  be_nil
        expect(store.adapter.get("es.boom")).to  be_nil

        expect(store.get(:en, :boom).missing?).to eq true
        expect(store.get(:es, :boom).missing?).to eq true
      end
    end

    describe "#import" do
      it "delegates to an importer instance with a file and itself" do
        file     = double(:is_a?  => true)
        importer = double(:import => true)
        expect(Store::Importer).to receive(:new).with(file, store).and_return(importer)
        store.import(file)
      end
    end
  end
end
