class Api::V1::Users::RecipeController < Api::V1::ApiController
  before_action :require_authentication!
  before_action :set_recipe, only: [:update]

  def index
    render json: query_recipe
  end

  def create
    recipe = @user.recipes.build recipe_params

    if recipe.save
      render json: recipe, status: :created
    else
      render json: { errors: recipe.errors},
             status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
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
    permit =  [ :ingredients, :name, :directions ]
    if @user.is_admin?
      permit << :status
    end
    params.permit(permit)
  end

  def query_recipe
    return Recipe.waiting_activation if (params['status'] == 'waiting_activation') && @user.is_admin?
    @user.recipes
  end

end
