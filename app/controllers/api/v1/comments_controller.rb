# frozen_string_literal: true

class Api::V1::CommentsController < Api::V1::ApiController
  before_action :require_authentication!, only: [:create]
  before_action :require_admin_authentication!, only: [:destroy]
  before_action :set_recipe

  def index
    render json: @recipe.comments.active
  end

  def create
    comment = @user.comments.build recipe: @recipe, text: params[:text]

    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors },
             status: :unprocessable_entity
    end
  end

  def destroy
    current_comment&.soft_delete @user
  end

  private

    def set_recipe
      @recipe = Recipe.find_by id: params[:recipe_id]
    end

    def current_comment
      Comment.find_by_id params[:id]
    end
end
