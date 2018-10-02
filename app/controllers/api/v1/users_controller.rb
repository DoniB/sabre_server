class Api::V1::UsersController < Api::V1::ApiController

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

end
