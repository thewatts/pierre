require "spec_helper"

module Pierre
  describe Store::OptionsSanitizer do
    describe "#initialize" do
      it "takes in options" do
        options = { hello: "world" }
        sanitizer = Store::OptionsSanitizer.new(options)
        expect(sanitizer.options).to eq options
      end
    end

    describe "#fallback" do
      it "defaults to true" do
        sanitizer = Store::OptionsSanitizer.new
        expect(sanitizer.fallback).to eq true
      end

      it "can be set to false" do
        options = {
          fallback: false
        }

        sanitizer = Store::OptionsSanitizer.new(options)
        expect(sanitizer.fallback).to eq false
      end
    end

    describe "#scope" do
      it "defaults to an empty array" do
        sanitizer = Store::OptionsSanitizer.new
        expect(sanitizer.scope).to eq []
      end

      it "can take in an array of symbols" do
        options = {
          scope: [:hello, :world]
        }
        sanitizer = Store::OptionsSanitizer.new(options)
        expect(sanitizer.scope).to eq [:hello, :world]
      end

      it "converts a concatenated string to an array of symbols" do
        options = {
          scope: "hello.world"
        }
        sanitizer = Store::OptionsSanitizer.new(options)
        expect(sanitizer.scope).to eq [:hello, :world]
      end
    end
  end
end
