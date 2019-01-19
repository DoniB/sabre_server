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
end
