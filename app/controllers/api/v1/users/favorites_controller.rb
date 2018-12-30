# frozen_string_literal: true

class Api::V1::Users::FavoritesController < Api::V1::ApiController
  before_action :set_user

  def index
    result = {}
    if @user
      result = @user.recipes_favorites.eager_load(:user, :cover)
    end
    render json: result
  end

  private

    def set_user
      load_user
    end
end
