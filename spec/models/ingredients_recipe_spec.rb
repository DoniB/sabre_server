# frozen_string_literal: true

require "rails_helper"

RSpec.describe IngredientsRecipe, type: :model do
  it "search for recipes ids by ingredients ids" do
    ingredients_for_search = []
    [
        "banana",
        "alho",
        "ovo",
        "frango",
        "leite condensado"
    ].each { |name| ingredients_for_search << create(:ingredient, name: name) }
    ingredients_for_search_ids = ingredients_for_search.map(&:id)

    ingredients = []
    [
        "ovomaltine",
        "creme de leite",
        "maça",
        "cebola",
        "macarrão"
    ].each { |name| ingredients << create(:ingredient, name: name) }

    expect(Ingredient.count).to eq(10)
    (1..ingredients.size).each { |size|
      ingredients.combination(size).each { |ingredients_combination|
        create(:recipe, ingredients_list: ingredients_combination)
      }
    }

    5.times { create :recipe, status: RecipeStatus::ACTIVE }

    result = IngredientsRecipe.recipes_ids_by_ingredients ingredients_for_search_ids
    expect(result.size).to eq(0)

    recipes = []
    (1..5).each { |total|
      recipes << create(:recipe, status: RecipeStatus::ACTIVE, ingredients_list: ingredients_for_search[0, total]).id
      result = IngredientsRecipe.recipes_ids_by_ingredients(ingredients_for_search_ids).sort
      expect(result.size).to eq(total)
      expect(result).to eq(recipes)
    }

    result = IngredientsRecipe.recipes_ids_by_ingredients(ingredients_for_search_ids)
    expect(result.size).to eq(5)

    20.times { create :recipe, status: RecipeStatus::ACTIVE, ingredients_list: [ingredients_for_search[0], ingredients[0] ] }
    result = IngredientsRecipe.recipes_ids_by_ingredients(ingredients_for_search_ids)
    expect(result.size).to eq(5)
  end
end
