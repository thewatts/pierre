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
  end
end
