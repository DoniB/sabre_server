# frozen_string_literal: true

class Api::V1::Users::RecipeController < Api::V1::ApiController
  before_action :require_authentication!
  before_action :set_recipe, only: %i[update show]

  def index
    render json: query_recipe
  end

  def show
    unless can_edit? @recipe
      return render json: { error: "You are not allowed to edit this recipe" }, status: :forbidden
    end

    render json: @recipe
  end

  def create
    @recipe = @user.recipes.build recipe_params
    if @recipe.save
      save_cover
      render json: @recipe, status: :created
    else
      render json: { errors: @recipe.errors },
             status: :unprocessable_entity
    end
  end

  def update
    unless can_edit? @recipe
      return render json: { error: "You are not allowed to edit this recipe" }, status: :forbidden
    end

    if @recipe.update(recipe_params)
      save_cover
      render json: @recipe, status: :accepted
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end

  private

    def set_recipe
      @recipe = Recipe.find params[:id]
    end

    def recipe_params
      permit =  %i[ingredients name directions category_id]
      permit << :status if @user.is_admin?
      params.permit(permit)
    end

    def query_recipe
      if @user.is_admin?
        waiting_activation = params["status"] == "waiting_activation"
        all_users = params["all_users"] == "1"

        recipes = all_users ? Recipe.all : @user.recipes
        recipes = recipes.waiting_activation if waiting_activation

        recipes
      else
        recipes = @user.recipes
      end

      query = params["q"]
      recipes = recipes.search(query) if query

      recipes
    end

    def can_edit?(recipe)
      return true if (recipe.user.id == @user.id) || @user.is_admin?
      false
    end

    def save_cover
      cover = params[:cover]
      unless cover.nil?
        if cover.instance_of? String
          cover = base64_to_image cover
        end
        Image.create file: cover, user: @user, recipe: @recipe
      end
    end
end
