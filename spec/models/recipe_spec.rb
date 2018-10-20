require 'rails_helper'
require 'recipe_status'

RSpec.describe Recipe, type: :model do
  it 'has valid factory' do
    expect(create(:recipe)).to be_valid
  end

  it 'create with WAITING_ACTIVATION status by default' do
    expect(create(:recipe).status).to eq(RecipeStatus::WAITING_ACTIVATION)
  end

  it 'is not valid without the ingredients' do
    recipe = build(:recipe, ingredients: nil)
    expect(recipe).to_not be_valid
  end

  it 'is not valid without the name' do
    recipe = build(:recipe, name: nil)
    expect(recipe).to_not be_valid
  end

  it 'is not valid without the directions' do
    recipe = build(:recipe, directions: nil)
    expect(recipe).to_not be_valid
  end

  it 'is not valid without the user' do
    recipe = build(:recipe, user: nil)
    expect(recipe).to_not be_valid
  end

  it 'is paginated' do
    recipe = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(0).first.id).to eq(recipe.id)
    recipe2 = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(1).first.id).to eq(recipe2.id)
    expect(recipe.id).to_not eq(recipe2.id)
  end

  it 'has default value paginated' do
    recipe = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page.first.id).to eq(recipe.id)
    recipe2 = create(:recipe)
    19.times { create(:recipe, user: recipe.user) }
    expect(Recipe.page(1).first.id).to eq(recipe2.id)
    expect(recipe.id).to_not eq(recipe2.id)
  end

end
