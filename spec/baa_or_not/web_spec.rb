# frozen_string_literal: true

require "rack/test"

RSpec.describe BaaOrNot::Web do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe "GET /" do
    it "returns the index page" do
      get "/"
      expect(last_response).to be_ok
    end

    it "contains the form" do
      get "/"
      expect(last_response.body).to include("Evaluate")
    end
  end

  describe "definitions section" do
    it "includes all four key definitions" do
      get "/"
      ["Covered Entity", "Business Associate", "PHI", "PII"].each do |term|
        expect(last_response.body).to include(term)
      end
    end
  end

  describe "GET /baa-or-not" do
    it "returns the index page" do
      get "/baa-or-not"
      expect(last_response).to be_ok
    end
  end

  describe "POST /baa-or-not/decide" do
    context "when all answers are yes" do
      it "indicates BAA is required" do
        post "/baa-or-not/decide",
             covered_entity: "yes",
             handles_phi: "yes",
             vendor_phi: "yes"

        expect(last_response.body).to include(
          "BAA likely required"
        )
      end
    end

    context "when not a covered entity" do
      it "indicates BAA may not be required" do
        post "/baa-or-not/decide",
             covered_entity: "no",
             handles_phi: "yes",
             vendor_phi: "yes"

        expect(last_response.body).to include(
          "BAA may not be required"
        )
      end
    end
  end
end
