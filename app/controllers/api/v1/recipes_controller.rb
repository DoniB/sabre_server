# frozen_string_literal: true

class Api::V1::RecipesController < Api::V1::ApiController
  before_action :set_recipe, only: [:show]

  def index
    render json: get_recipes
  end

  def show
    if @recipe
      return render json: @recipe
    end
    render json: {}, status: :not_found
  end

  private

    def get_recipes
      return get_recipes_by_ingredients if params[:by_ingredients] && params[:q]
      @recipes = Recipe.active.page(params[:page])
      filter_recipes_by_query
      filter_recipes_by_category
      @recipes
    end

    def get_recipes_by_ingredients
      Recipe.by_ingredients_list params[:q]
    end

    def filter_recipes_by_query
      query = params[:q]
      @recipes = @recipes.search(query) if query
    end

    def filter_recipes_by_category
      category = params[:category]
      @recipes = @recipes.category(category) if category.to_i > 0
    end

    def set_recipe
      @recipe = Recipe.active.find_by(id: params[:id])
    end
end
