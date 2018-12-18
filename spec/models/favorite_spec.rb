# frozen_string_literal: true

require "rails_helper"

RSpec.describe Favorite, type: :model do
  it "has a valid factory" do
    favorite = create(:favorite)
    expect(favorite).to be_valid
  end

  it "validates user" do
    favorite = build(:favorite, user: nil)
    expect(favorite).to_not be_valid
    favorite = build(:favorite)
    expect(favorite).to be_valid
    expect(favorite.user).to_not be_nil
  end

  it "validates recipe" do
    favorite = build(:favorite, recipe: nil)
    expect(favorite).to_not be_valid
    favorite = build(:favorite)
    expect(favorite).to be_valid
    expect(favorite.recipe).to_not be_nil
  end

  it "should should create only one favorite with the same recipe and user" do
    favorite = create(:favorite)
    expect(favorite).to be_valid
    favorite2 = build(:favorite, recipe: favorite.recipe, user: favorite.user)
    expect(favorite2).to_not be_valid
  end
end
