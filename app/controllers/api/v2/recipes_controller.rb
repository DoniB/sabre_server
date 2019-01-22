# frozen_string_literal: true

class Api::V2::RecipesController < ApplicationController
  def index
    render json: get_recipes
  end

  private

    def get_recipes
      @recipes = Recipe.active.page(params[:page])
      filter_recipes_by_category
      if params[:by_ingredients] && params[:q]
        filter_recipes_by_ingredients
      else
        filter_recipes_by_query
      end
      @recipes
    end

    def filter_recipes_by_query
      query = params[:q]
      @recipes = @recipes.search(query) if query
    end

    def filter_recipes_by_category
      category = params[:category]
      @recipes = @recipes.category(category) if category.to_i > 0
    end

    def filter_recipes_by_ingredients
      ingredients_ids = Ingredient.from_comma_list(params[:q]).map(&:id)
      recipes_ids = IngredientsRecipe.recipes_ids_by_ingredients ingredients_ids
      return (@recipes = []) if recipes_ids.empty?

      @recipes = @recipes.where(id: recipes_ids)
    end
end
