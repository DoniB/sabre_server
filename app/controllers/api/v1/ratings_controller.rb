class Api::V1::RatingsController < Api::V1::ApiController
  before_action :require_authentication!
  before_action :set_rating, only: [:show]
  before_action :set_recipe, only: [:create]

  def show
    render json: @rating
  end

  def create
    rating = @user.ratings.build recipe: @recipe, stars: params[:stars]

    if rating.save
      render json: rating, status: :created
    else
      render json: { errors: rating.errors},
             status: :unprocessable_entity
    end
  end

  private

  def set_rating
    @rating = @user.ratings.find_by recipe_id: params[:recipe_id]
  end

  def set_recipe
    @recipe = Recipe.find_by id: params[:recipe_id]
  end
end
