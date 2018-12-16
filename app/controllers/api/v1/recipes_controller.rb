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
      recipes = Recipe.active.page(page)
      query = params[:q]
      recipes = recipes.search(query) unless query.nil?
      category = params[:category]
      recipes = recipes.category(category) if !category.nil? && category.to_i > 0
      recipes
    end

    def page
      params["page"]&.to_i || 0
    end

    def set_recipe
      @recipe = Recipe.active.find_by(id: params[:id])
    end
end
