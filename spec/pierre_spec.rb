require "spec_helper"

describe Pierre do
  describe "::VERSION" do
    it "is a string" do
      expect(Pierre::VERSION).to be_kind_of String
    end
  end
end
