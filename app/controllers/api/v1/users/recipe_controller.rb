class Api::V1::Users::RecipeController < Api::V1::ApiController
  before_action :require_authentication!
  before_action :set_recipe, only: [:update, :show]

  def index
    render json: query_recipe
  end

  def show
    unless can_edit? @recipe
      return render json: { error: 'You are not allowed to edit this recipe'}, status: :forbidden
    end
    render json: @recipe
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
    unless can_edit? @recipe
      return render json: { error: 'You are not allowed to edit this recipe'}, status: :forbidden
    end

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

  def can_edit?(recipe)
    return true if(recipe.user.id == @user.id) || @user.is_admin?
    false
  end

end
