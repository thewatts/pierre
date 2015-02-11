require "spec_helper"
require "./lib/pierre/store"

describe Pierre do
  describe "::VERSION" do
    it "is a string" do
      expect(Pierre::VERSION).to be_kind_of String
    end
  end

  describe "Getters and Setters" do
    let(:store) { instance_double(Pierre::Store) }

    before do
      allow(Pierre).to receive(:store).and_return(store)
    end

    describe ".set" do
      it "tells the store to add a translation" do
        options = { context: "A welcome message for the masses." }
        expect(store).to receive(:set).with(
          :en, :welcome_message, "Hello World", options
        )

        Pierre.set(:en, :welcome_message, "Hello World", options)
      end
    end

    describe ".get" do
      it "asks the store for a translation" do
        options = { fallback: true }
        expect(store).to receive(:get).with(:en, :welcome_message, options)
        Pierre.get(:en, :welcome_message)
      end
    end

    describe ".keys" do
      it "asks the store for the keys for a language" do
        expect(store).to receive(:keys).with(:en)
        Pierre.keys(:en)
      end
    end

    describe ".manage" do
      it "delegates to the store" do
        options = { reference: :en }
        expect(store).to receive(:manage).with(:es, options)
        Pierre.manage(:es)
      end
    end

    describe ".i18n_adapter" do
      it "instantiates a new i18n adapter with the store" do
        store = double
        allow(Pierre).to receive(:store).and_return(store)

        adapter = Pierre.i18n_adapter
        expect(adapter).to be_kind_of Pierre::I18nAdapter
        expect(adapter.store).to eq store
      end
    end

    describe ".store" do
      before do
        allow(Pierre).to receive(:store).and_call_original
      end

      it "gets the store from the configuration" do
        configuration = double(store: store)
        allow(Pierre).to receive(:configuration).and_return(configuration)

        expect(Pierre.store).to eq store
      end
    end

    describe ".dump" do
      it "delegates out to the store" do
        expect(store).to receive(:dump).with(:en)
        Pierre.dump(:en)
      end
    end

    describe ".configuration" do
      it "creates a new Pierre::Configuration" do
        expect(Pierre::Configuration).to receive(:new)
        Pierre.configuration
      end
    end

    describe ".configure" do
      it "yields to the configuration" do
        expect { |block| Pierre.configure(&block) }
          .to yield_control
      end
    end
  end
end
