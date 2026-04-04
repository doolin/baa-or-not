# frozen_string_literal: true

RSpec.describe BaaOrNot::Decision do
  subject(:decision) { described_class.new(answers) }

  describe "#required?" do
    context "when all three conditions are true" do
      let(:answers) do
        {
          covered_entity: true,
          handles_phi: true,
          vendor_phi: true,
        }
      end

      it "returns true" do
        expect(decision).to be_required
      end
    end

    context "when not a covered entity" do
      let(:answers) do
        {
          covered_entity: false,
          handles_phi: true,
          vendor_phi: true,
        }
      end

      it "returns false" do
        expect(decision).not_to be_required
      end
    end

    context "when no PHI is handled" do
      let(:answers) do
        {
          covered_entity: true,
          handles_phi: false,
          vendor_phi: true,
        }
      end

      it "returns false" do
        expect(decision).not_to be_required
      end
    end

    context "when no vendor processes PHI" do
      let(:answers) do
        {
          covered_entity: true,
          handles_phi: true,
          vendor_phi: false,
        }
      end

      it "returns false" do
        expect(decision).not_to be_required
      end
    end

    context "with no answers" do
      let(:answers) { {} }

      it "returns false" do
        expect(decision).not_to be_required
      end
    end
  end

  describe "#determination" do
    context "when BAA is required" do
      let(:answers) do
        {
          covered_entity: true,
          handles_phi: true,
          vendor_phi: true,
        }
      end

      it "returns the required message" do
        expect(decision.determination).to eq(
          "BAA likely required"
        )
      end
    end

    context "when BAA is not required" do
      let(:answers) do
        {
          covered_entity: false,
          handles_phi: false,
          vendor_phi: false,
        }
      end

      it "returns the not-required message" do
        expect(decision.determination).to eq(
          "BAA may not be required"
        )
      end
    end
  end
end
