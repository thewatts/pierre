require "spec_helper"
require "./lib/pierre/translation"

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
          fallback_text: "Hello Wonderful World!",
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

        context "with a scoped key" do
          it "correctly pulls out the scopes from the key" do
            attributes[:key] = "down.more.levels.heading"
            expect(translation.key).to   eq :heading
            expect(translation.scope).to eq [:down, :more, :levels]
          end
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

      describe "#fallback_text" do
        it "initializes with a fallback_text" do
          expect(translation.fallback_text).to eq "Hello Wonderful World!"
        end

        it "defaults to 'Missing Translation'" do
          attributes[:fallback_text] = nil
          expect(translation.fallback_text).to eq "Missing Translation"
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

      describe "#missing?" do
        context "when text is missing" do
          it "is true" do
            attributes[:text] = nil
            expect(translation.missing?).to be true
          end
        end

        context "when text is present" do
          it "is false" do
            attributes[:text] = "BOOM"
            expect(translation.missing?).to be false
          end
        end
      end

      describe "#fallback?" do
        it "is true if set to true" do
          attributes[:fallback] = true
          expect(translation.fallback?).to be true
        end

        it "is false by default" do
          expect(translation.fallback?).to be false
        end
      end

      describe "#to_json" do
        it "creates a jsonified version of the Translation" do
          expected = {
            key: attributes[:key],
            lang: attributes[:lang],
            text: attributes[:text],
            context: attributes[:context],
            missing: translation.missing?
          }.to_json

          expect(translation.to_json).to eq expected
        end
      end

      describe "#scope" do
        it "pulls the default scope it not initialized with one" do
          attributes[:scope] = nil
          expect(translation.scope).to eq []
        end

        it "pulls the scope if initialized with it" do
          attributes[:scope] = [:hello, :world]
          expect(translation.scope).to eq [:hello, :world]
        end

        it "converts the scope if it's a string" do
          attributes[:scope] = "hello.world"
          expect(translation.scope).to eq [:hello, :world]
        end
      end
    end
  end
end
