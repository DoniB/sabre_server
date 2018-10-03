class Api::V1::UsersController < Api::V1::ApiController

  before_action :require_authentication!, only: [:show]

  def create
    user = User.new params.permit(:username,
                                  :email,
                                  :password,
                                  :password_confirmation)

    if user.save
      token = user.secure_tokens.create
      response = user.as_json(except: user_hidden_fields).merge(token: token.token, expires: token.expires)
      render json: response, status: :created
    else
      render json: { errors: user.errors},
             status: :unprocessable_entity
    end
  end

  def show
    token = SecureToken.find_by token: request.headers['X-Secure-Token']
    response = @user.as_json(except: user_hidden_fields).merge(token: token.token, expires: token.expires)
    render json: response
  end

end
