# frozen_string_literal: true

RSpec.describe BaaOrNot do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  it "defines a REVISION constant" do
    expect(described_class.const_defined?(:REVISION)).to be true
  end
end
