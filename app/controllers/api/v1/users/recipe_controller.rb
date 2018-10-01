class Api::V1::Users::RecipeController < Api::V1::ApiController
  before_action :require_authentication!

  def create
    recipe = @user.recipes.build params.permit(:ingredients, :name, :directions)

    if recipe.save
      render json: recipe, status: :created
    else
      render json: { errors: recipe.errors},
             status: :unprocessable_entity
    end
  end

end
