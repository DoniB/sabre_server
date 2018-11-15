class Api::V1::Adm::UsersController < Api::V1::ApiController

  before_action :require_admin_authentication!
  before_action :load_users, only: [:index]
  before_action -> { @user = User.find_by id: params[:id] }, only: [:update]

  def index
    render json: {
        page: {
            current: @current_page,
            total: @total_pages
        },
        users: @users
    }
  end

  def create
    user = User.new user_params

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors},
             status: :unprocessable_entity
    end
  end

  def update

    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors},
             status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username,
                  :email,
                  :is_admin,
                  :password)
  end

  def load_users
    @users = User.page params[:page].to_i
    q = params[:q]
    @users = @users.search(q) unless q.nil?
    @total_pages = @users.total_pages
    @current_page = params[:page].to_i
  end

end
