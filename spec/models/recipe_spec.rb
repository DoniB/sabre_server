# frozen_string_literal: true

require "rails_helper"
require "recipe_status"

RSpec.describe Recipe, type: :model do
  it "has valid factory" do
    expect(create(:recipe)).to be_valid
  end

  it "create with WAITING_ACTIVATION status by default" do
    expect(create(:recipe).status).to eq(RecipeStatus::WAITING_ACTIVATION)
  end

  it "is not valid without the ingredients" do
    recipe = build(:recipe, ingredients: nil)
    expect(recipe).to_not be_valid
  end

  it "is not valid without the name" do
    recipe = build(:recipe, name: nil)
    expect(recipe).to_not be_valid
  end

  it "is not valid without the directions" do
    recipe = build(:recipe, directions: nil)
    expect(recipe).to_not be_valid
  end

  it "is not valid without the user" do
    recipe = build(:recipe, user: nil)
    expect(recipe).to_not be_valid
  end

  it "is not valid without the category" do
    recipe = build(:recipe, category: nil)
    expect(recipe).to_not be_valid
  end

  it "has ratings" do
    recipe = create(:recipe)
    expect(recipe.ratings.count).to eq(0)

    rating = create(:rating, recipe: recipe)
    expect(Rating.count).to eq(1)
    expect(recipe.ratings.count).to eq(1)
    expect(recipe.ratings.first.id).to eq(rating.id)

    create(:rating)
    expect(Rating.count).to eq(2)
    expect(recipe.ratings.count).to eq(1)
    expect(recipe.ratings.first.id).to eq(rating.id)

    rating = build(:rating, recipe: recipe)
    recipe.ratings.create(stars: rating.stars, user: rating.user).id
    expect(Rating.count).to eq(3)
    expect(recipe.ratings.count).to eq(2)
  end

  it "has average stars" do
    recipe = create(:recipe)
    expect(recipe.average_stars).to eq(0)

    recipe = create(:recipe, average_stars: 5)
    expect(recipe.average_stars).to eq(5)

    recipe = build(:recipe, average_stars: -1)
    expect(recipe).to_not be_valid

    recipe = build(:recipe, average_stars: -1)
    expect(recipe).to_not be_valid
  end

  it "has average_stars recalculated" do
    recipe = create(:recipe)
    expect(recipe.average_stars).to eq(0)

    expect(recipe.ratings.count).to eq(0)

    rating = create(:rating, recipe: recipe, stars: 2)
    expect(recipe.ratings.count).to eq(1)
    expect(recipe.reload.average_stars).to eq(2)

    rating2 = create(:rating, recipe: recipe, stars: 4)
    expect(recipe.ratings.count).to eq(2)
    expect(recipe.reload.average_stars).to eq(3)

    rating.stars = 5
    rating.save
    expect(recipe.reload.average_stars).to eq(4)

    rating2.destroy
    expect(recipe.ratings.count).to eq(1)
    expect(recipe.reload.average_stars).to eq(5)
  end

  it "is paginated" do
    recipe = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(0).last.id).to eq(recipe.id)
    recipe2 = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(0).last.id).to eq(recipe2.id)
    expect(Recipe.page(1).last.id).to eq(recipe.id)
    expect(recipe.id).to_not eq(recipe2.id)
  end

  it "has default value paginated" do
    recipe = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page.last.id).to eq(recipe.id)
    recipe2 = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(0).last.id).to eq(recipe2.id)
    expect(Recipe.page(1).last.id).to eq(recipe.id)
    expect(recipe.id).to_not eq(recipe2.id)
  end

  it "has a search scope" do
    recipe = create(:recipe, name: "recipe", ingredients: "ingredient ingredient")
    create(:recipe, name: "another", ingredients: "anything something")
    result = Recipe.search "recipe"

    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(recipe.id)
  end

  it "has a category scope" do
    category = create(:category)
    recipe = create(:recipe, category: category)

    recipes = Recipe.category(category.id)
    expect(recipes.count).to eq(1)
    expect(recipes.first.id).to eq(recipe.id)

    create(:recipe, category: category)
    recipes = Recipe.category(category.id)
    expect(recipes.count).to eq(2)
    expect(Recipe.count).to eq(2)

    create(:recipe, category: create(:category))
    recipes = Recipe.category(category.id)
    expect(recipes.count).to eq(2)
    expect(Recipe.count).to eq(3)
  end

  it "s search scope does not show wrong result" do
    create(:recipe, name: "another", ingredients: "anything something")
    result = Recipe.search "recipe"

    expect(result).to_not be_nil
    expect(result.count).to eq(0)
  end

  it "s search scope show result for similar words" do
    recipe = create(:recipe, name: "receitas caseiras", ingredients: "ingredientes abundantes")

    result = Recipe.search "receita"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(recipe.id)

    result = Recipe.search "ingrediente"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(recipe.id)

    result = Recipe.search "abundante"
    expect(result).to_not be_nil
    expect(result.count).to eq(1)
    expect(result.first.id).to eq(recipe.id)
  end
end
