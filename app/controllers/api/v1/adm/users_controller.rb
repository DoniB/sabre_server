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

  private

  def load_page
    @current_page = params[:page].to_i
  end

end
