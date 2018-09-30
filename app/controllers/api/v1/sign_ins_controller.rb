class Api::V1::SignInsController < Api::V1::ApiController

  def create
    user = load_user
    if user
      token = user.secure_tokens.create
      response = user.as_json(except: user_hidden_fields).merge(token: token.token, expires: token.expires)
      render json: response, status: :created
    else
      render json: { errors: 'wrong email or password' }
    end
  end

  private
  def load_user
    user = User.find_by email: params[:email]
    return nil if user.nil? || !user.authenticate(params[:password])
    user
  end

end
