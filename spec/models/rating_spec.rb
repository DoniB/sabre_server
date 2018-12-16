# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rating, type: :model do
  it "has a valid factory" do
    rating = create(:rating)
    expect(rating).to be_valid
  end

  it "validates stars" do
    rating = build(:rating, stars: -1)
    expect(rating).to_not be_valid

    rating = build(:rating, stars: 6)
    expect(rating).to_not be_valid

    5.times do |t|
      rating = build(:rating, stars: t)
      expect(rating).to be_valid
    end

    rating = build(:rating, stars: "a")
    expect(rating).to_not be_valid

    rating = build(:rating, stars: "1")
    expect(rating).to be_valid
  end

  it "validates user" do
    rating = build(:rating, user: nil)
    expect(rating).to_not be_valid
    rating = build(:rating)
    expect(rating).to be_valid
    expect(rating.user).to_not be_nil
  end

  it "validates recipe" do
    rating = build(:rating, recipe: nil)
    expect(rating).to_not be_valid
    rating = build(:rating)
    expect(rating).to be_valid
    expect(rating.recipe).to_not be_nil
  end

  it "should should create only one rating with the same recipe and user" do
    rating = create(:rating)
    expect(rating).to be_valid
    rating2 = build(:rating, recipe: rating.recipe, user: rating.user)
    expect(rating2).to_not be_valid
  end
end
