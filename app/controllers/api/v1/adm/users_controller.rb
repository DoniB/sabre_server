# frozen_string_literal: true

class Api::V1::Adm::UsersController < Api::V1::ApiController
  before_action :require_admin_authentication!
  before_action :load_users, only: [:index]
  before_action -> { @user = User.find_by id: params[:id] }, only: [:update, :show]

  def index
    render json: {
        page: {
            current: @current_page,
            total: @total_pages
        },
        users: @users
    }
  end

  def show
    render json: @user
  end

  def create
    user = User.new user_params

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors },
             status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors },
             status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.permit(:username,
                    :email,
                    :is_admin,
                    :password,
                    :active)
    end

    def load_users
      @current_page = params[:page].to_i
      @users = User.page @current_page
      q = params[:q]

      if q.nil?
        @total_pages = User.total_pages
      else
        @users = @users.search(q)
        @total_pages = User.search(q).total_pages
      end
    end
end
