require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it 'has valid factory' do
    expect(create(:recipe)).to be_valid
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

end
