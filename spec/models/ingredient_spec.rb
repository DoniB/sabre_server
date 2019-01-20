# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ingredient, type: :model do
  it "has a valid factory" do
    ingredient = build(:ingredient)
    expect(ingredient).to be_valid
  end

  it "has a unique name" do
    ingredient = create :ingredient
    ingredient = build(:ingredient, name: ingredient.name)
    expect(ingredient).to_not be_valid
  end

  it "requires a name" do
    ingredient = build(:ingredient, name: nil)
    expect(ingredient).to_not be_valid
  end

  it "has recipes" do
    ingredient = create(:ingredient)
    expect(ingredient.recipes.count).to eq(0)
    recipe = create(:recipe)
    ingredient.recipes << recipe
    expect(ingredient.recipes.count).to eq(1)
    expect(recipe.ingredients_list.count).to eq(1)
  end

  it "has search scope" do
    ingredient = create(:ingredient, name: "ingredients")
    ingredient2 = create(:ingredient, name: "another")

    result = Ingredient.trigram_search "ano fher"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(ingredient2.id)

    result = Ingredient.fuzzy_search "ingredient"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(ingredient.id)

    result = Ingredient.search "ano fher"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(ingredient2.id)

    result = Ingredient.search "ingredient"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(ingredient.id)
  end

  it "find ingredients by string" do
    INGREDIENTS_NAME = %w(banana alho frango maçã cebola macarrão)
    INGREDIENTS = INGREDIENTS_NAME.map { |i| create(:ingredient, name: i) }

    (1..6).each do |amount|
      INGREDIENTS_NAME.combination(amount).each do |for_search|
        result = Ingredient.from_comma_list for_search.join ", "
        expect(result.size).to eq amount
        result.each { |r|
          expect(for_search).to include r.name
        }
      end
    end
  end
end
