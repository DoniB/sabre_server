class Api::V1::CommentsController < Api::V1::ApiController
  before_action :require_authentication!, only: [:create]
  before_action :set_recipe

  def index
    render json: @recipe.comments
  end

  def create
    comment = @user.comments.build recipe: @recipe, text: params[:text]

    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors},
             status: :unprocessable_entity
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find_by id: params[:recipe_id]
  end

end
