# frozen_string_literal: true

class IngredientsRecipe < ApplicationRecord
  def self.recipes_ids_by_ingredients(ingredients_ids)
    recipes_ids = recipes_with_valid_ingredients(ingredients_ids)
    filter_recipes(recipes_ids, ingredients_ids)
  end

  private
    def self.recipes_with_valid_ingredients(ingredients_ids)
      return [] if ingredients_ids.empty?
      select(:recipe_id).
      where(ingredient_id: ingredients_ids).
      group(:recipe_id).
      map(&:recipe_id)
    end

    def self.filter_recipes(recipes_ids, ingredients_ids)
      return [] if recipes_ids.empty? || ingredients_ids.empty?
      recipes_ids - select(:recipe_id).
          where.not(ingredient_id: ingredients_ids).
          where(recipe_id: recipes_ids).
          group(:recipe_id).map(&:recipe_id).sort
    end
end
