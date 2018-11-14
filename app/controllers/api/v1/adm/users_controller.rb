class Api::V1::Adm::UsersController < Api::V1::ApiController

  before_action :require_admin_authentication!
  before_action :load_page

  def index
    render json: {
        page: {
            current: @current_page,
            total: User.total_pages
        },
        users: User.page(@current_page)
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

  private

  def user_params
    params.permit(:username,
                  :email,
                  :is_admin,
                  :password)
  end

  def load_page
    @current_page = params[:page].to_i
  end

end
