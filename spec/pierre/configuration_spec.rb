require "spec_helper"

module Pierre
  describe Configuration do
    let(:config) { Configuration.new }

    describe "#store" do
      it "defaults to nil" do
        expect(config.store).to be_nil
      end
    end

    describe "#store=" do
      it "assigns a store" do
        store = double
        config.store = store
        expect(config.store).to eq store
      end
    end
  end
end
