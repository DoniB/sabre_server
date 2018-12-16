# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  it "has valid factory" do
    category = create(:category)
    expect(category).to be_valid
  end

  it "requires name" do
    category = build(:category, name: nil)
    expect(category).to_not be_valid
  end

  it "has recipes" do
    category = create(:category)
    other_category = create(:category)
    5.times { create(:recipe, category: category, status: RecipeStatus::ACTIVE) }
    expect(category.recipes.count).to eq(5)
    5.times { create(:recipe, category: other_category, status: RecipeStatus::ACTIVE) }
    expect(Recipe.count).to eq(10)
    expect(category.recipes.count).to eq(5)
  end

  it "has recipes active only" do
    category = create(:category)
    other_category = create(:category)
    5.times { create(:recipe, category: category) }
    5.times { create(:recipe, category: category, status: RecipeStatus::ACTIVE) }
    expect(category.recipes.count).to eq(10)
    expect(category.recipes.active.count).to eq(5)
    5.times { create(:recipe, category: other_category, status: RecipeStatus::ACTIVE) }
    expect(Recipe.count).to eq(15)
    expect(category.recipes.count).to eq(10)
    expect(category.recipes.active.count).to eq(5)
  end
end
