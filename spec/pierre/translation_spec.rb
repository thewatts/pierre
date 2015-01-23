require "spec_helper"

module Pierre
  describe Translation do
    describe "#initialize" do
      it "initializes with attributes" do
        attributes  = {}
        translation = Translation.new(attributes)
        expect(translation.attributes).to eq attributes
      end
    end

    describe "Attributes" do
      let(:attributes) {
        {
          lang: "en",
          key: "welcome_message",
          text: "Hello World!",
          context: "A welcome message for users",
          fallback: "Hello Wonderful World!",
        }
      }

      let(:translation) { Translation.new(attributes) }

      describe "#lang" do
        it "initializes with a lang, converting it to a symbol" do
          expect(translation.lang).to eq :en
        end

        it "is nil if not set" do
          attributes[:lang] = nil
          expect(translation.lang).to eq nil
        end
      end

      describe "#key" do
        it "initializes with a key, converting it to a symbol" do
          expect(translation.key).to eq :welcome_message
        end

        it "is nil if not set" do
          attributes[:key] = nil
          expect(translation.key).to eq nil
        end
      end

      describe "#text" do
        it "initializes with text" do
          expect(translation.text).to eq "Hello World!"
        end
      end

      describe "#context" do
        it "initializes with context" do
          expect(translation.context).to eq "A welcome message for users"
        end
      end

      describe "#fallback" do
        it "initializes with a fallback" do
          expect(translation.fallback).to eq "Hello Wonderful World!"
        end

        context "when text is nil" do
          it "is used instead" do
            attributes[:text] = nil
            expect(translation.text).to eq "Hello Wonderful World!"
          end
        end

        context "when text is empty" do
          it "is used instead" do
            attributes[:text] = ""
            expect(translation.text).to eq "Hello Wonderful World!"
          end
        end
      end
    end
  end
end
