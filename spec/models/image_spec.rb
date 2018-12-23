# frozen_string_literal: true

require "rails_helper"

RSpec.describe Image, type: :model do
  it "has a valid factory" do
    image = build(:image)
    expect(image).to be_valid
  end

  it "requires an user" do
    image = build(:image, user: nil)
    expect(image).to_not be_valid
  end

  it "does not require an recipe" do
    image = build(:image, recipe: nil)
    expect(image).to be_valid
  end

  it "requires a file" do
    image = build(:image, file: nil)
    expect(image).to_not be_valid
  end
end
