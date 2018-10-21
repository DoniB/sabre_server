class Api::V1::RecipesController < Api::V1::ApiController

  before_action :set_recipe, only: [:show]

  def index
    render json: Recipe.active.page(page)
  end

  def show
    if @recipe
      return render json: @recipe
    end
    render json: {}, status: :not_found
  end

  private

  def page
    params['page']&.to_i || 0
  end

  def set_recipe
    @recipe = Recipe.active.find_by(id: params[:id])
  end

end
