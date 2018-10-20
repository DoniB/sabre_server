class Api::V1::RecipesController < Api::V1::ApiController

  def index
    render json: Recipe.active.page(page)
  end

  private

  def page
    params['page']&.to_i || 0
  end

end
