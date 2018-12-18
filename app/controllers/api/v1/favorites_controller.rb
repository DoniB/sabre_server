# frozen_string_literal: true

class Api::V1::FavoritesController < Api::V1::ApiController
  before_action :set_favorite

  def show
    render json: { favorite: !!@favorite }
  end

  def destroy
    @favorite&.destroy
    render json: { favorite: false }
  end

  def create
    recipe = Recipe.find_by_id params[:recipe_id]
    if @user && !@favorite && recipe
      @favorite = @user.favorites.create recipe: recipe
    end
    render json: { favorite: !!@favorite }
  end

  private

    def set_favorite
      load_user
      @favorite = @user&.favorites&.find_by recipe_id: params["recipe_id"]
    end
end
