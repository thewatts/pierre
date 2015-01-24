require "spec_helper"

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
      it "returns a Translation with the correct values" do
        options = { context: "A welcome message for the masses." }
        expect(store).to receive(:set).with(
          :en, :welcome_message, "Hello World", options
        )

        Pierre.set(:en, :welcome_message, "Hello World", options)
      end
    end

    describe ".get" do
      it "returns a Translation with the correct values" do
        expect(store).to receive(:get).with(:en, :welcome_message)
        Pierre.get(:en, :welcome_message)
      end
    end
  end
end
