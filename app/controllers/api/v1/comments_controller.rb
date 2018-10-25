class Api::V1::CommentsController < Api::V1::ApiController
  before_action :require_authentication!
  before_action :set_recipe

  def create
    comment = @user.comments.build comment_params

    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors},
             status: :unprocessable_entity
    end
  end

  private

  def comment_params
    {text: params[:text], recipe: @recipe}
  end

  def set_recipe
    @recipe = Recipe.find_by id: params[:recipe_id]
  end

end
